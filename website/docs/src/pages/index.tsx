import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';

const features = [
  {
    label: 'Skills',
    title: '51 structured commands',
    description:
      'Across 13 roles — PM, Dev, Backend, Frontend, QA, UX, Data, Detect, WP, Release, Security, DevOps, and Core. Each skill knows its questions, its template, and its output format.',
  },
  {
    label: 'Two-Phase Workflow',
    title: 'Human approval built in',
    description:
      'Read-only analysis first. Hard stop for your approval. Then generation. Nothing ships without your say.',
  },
  {
    label: 'Learning System',
    title: 'Gets better over time',
    description:
      'Every skill remembers past feedback via LEARN.md files. Lessons route to skill, template, or context learning.',
  },
];

const roles = [
  {name: 'PM', skills: ['pm-prd-write', 'pm-story-write', 'pm-research-about', 'pm-roadmap-add', 'pm-roadmap-update']},
  {name: 'Backend', skills: ['backend-api-contract', 'backend-data-model', 'backend-task-breakdown', 'backend-scaffold', 'backend-service-implement']},
  {name: 'Frontend', skills: ['frontend-design', 'frontend-task-breakdown', 'frontend-scaffold']},
  {name: 'Dev', skills: ['dev-project-assemble', 'detect-dev']},
  {name: 'QA', skills: ['qa-test-cases', 'qa-test-generate']},
  {name: 'UX', skills: ['ux-heatmap-analyze', 'ux-microcopy-write', 'ux-research-synthesize', 'ux-flowchart-generate']},
  {name: 'Security', skills: ['sec-audit-remediate']},
  {name: 'DevOps', skills: ['devops-infra-scaffold']},
  {name: 'Detect', skills: ['detect-design', 'detect-writing', 'detect-product', 'detect-ux', 'detect-pack']},
  {name: 'Data', skills: ['data-gtm-datalayer']},
  {name: 'Release', skills: ['release-iterate-changelog']},
  {name: 'WP', skills: ['wp-pr-review']},
  {name: 'Core', skills: ['docs-create', 'docs-update', 'learn-add', 'skill-create', 'skill-update', 'jaan-init', 'jaan-issue-report']},
];

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link className="button button--primary button--lg" to="/docs/getting-started">
            Get Started
          </Link>
          <Link className="button button--secondary button--lg" to="/docs/skills/">
            Browse Skills
          </Link>
        </div>
      </div>
    </header>
  );
}

function Features() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {features.map(({label, title, description}) => (
            <div key={label} className={clsx('col col--4')}>
              <div className="feature-card">
                <div className="feature-card__label">{label}</div>
                <h3>{title}</h3>
                <p>{description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function SkillCategories() {
  return (
    <section className={styles.skills}>
      <div className="container">
        <div style={{textAlign: 'center', marginBottom: '2rem'}}>
          <Heading as="h2">Skills by Role</Heading>
          <p style={{color: '#6b6b6b'}}>51 skills across 13 roles + 1 MCP connector. Run any skill with <code>/jaan-to:skill-name</code></p>
        </div>
        <div className="row">
          {roles.map(({name, skills}) => (
            <div key={name} className={clsx('col col--4')} style={{marginBottom: '2rem'}}>
              <h3 style={{borderLeft: '2px solid #dd2e44', paddingLeft: '12px', fontSize: '1.1rem'}}>
                {name} <span style={{color: '#aeaeb2', fontWeight: 400, fontSize: '0.85rem'}}>({skills.length})</span>
              </h3>
              <ul style={{listStyle: 'none', padding: 0, margin: 0}}>
                {skills.map((skill) => (
                  <li key={skill} style={{marginBottom: '4px'}}>
                    <code style={{fontSize: '0.82rem'}}>/jaan-to:{skill}</code>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function QuickExample() {
  return (
    <section className={styles.example}>
      <div className="container" style={{maxWidth: '640px'}}>
        <div style={{textAlign: 'center', marginBottom: '1.5rem'}}>
          <Heading as="h2">Try it now</Heading>
        </div>
        <div className="terminal-block">
          <span className="prompt">$</span> <span className="command">claude</span><br />
          <span className="prompt">$</span> <span className="command">/plugin marketplace add parhumm/jaan-to</span><br />
          <span className="prompt">$</span> <span className="command">/jaan-to:pm-prd-write &quot;user authentication&quot;</span>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  return (
    <Layout
      title="Documentation"
      description="jaan.to documentation — a workflow layer for Claude Code. 51 skills across 13 roles.">
      <HomepageHeader />
      <main>
        <Features />
        <SkillCategories />
        <QuickExample />
      </main>
    </Layout>
  );
}
