import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'jaan.to Docs',
  tagline: 'Give soul to your workflow',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://docs.jaan.to',
  baseUrl: '/',

  organizationName: 'parhumm',
  projectName: 'jaan-to',

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  markdown: {
    format: 'md',
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  headTags: [
    {
      tagName: 'link',
      attributes: {
        rel: 'preconnect',
        href: 'https://fonts.googleapis.com',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'preconnect',
        href: 'https://fonts.gstatic.com',
        crossorigin: 'anonymous',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300..900;1,9..144,300..900&display=swap',
      },
    },
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          path: '../../docs',
          routeBasePath: 'docs',
          sidebarPath: './sidebars.ts',
          exclude: [
            'STYLE.md',
            'QUICKSTART-VIDEO.md',
            'development/**',
            'learning/LESSON-TEMPLATE.md',
          ],
          editUrl: 'https://github.com/parhumm/jaan-to/edit/main/docs/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themes: [
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        indexBlog: false,
        docsRouteBasePath: '/docs',
      },
    ],
  ],

  themeConfig: {
    image: 'img/favicon-32x32.png',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'jaan.to',
      logo: {
        alt: 'jaan.to',
        src: 'img/favicon-32x32.png',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {to: '/changelog-product', label: 'What\'s New', position: 'left'},
        {to: '/changelog', label: 'Changelog', position: 'left'},
        {
          href: 'https://jaan.to',
          label: 'jaan.to',
          position: 'right',
        },
        {
          href: 'https://github.com/parhumm/jaan-to',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {label: 'Getting Started', to: '/docs/getting-started'},
            {label: 'Skills', to: '/docs/skills/'},
            {label: 'Configuration', to: '/docs/config/'},
            {label: 'Extending', to: '/docs/extending/'},
          ],
        },
        {
          title: 'Content',
          items: [
            {label: 'What\'s New', to: '/changelog-product'},
            {label: 'Changelog', to: '/changelog'},
            {label: 'Contributing', to: '/contributing'},
          ],
        },
        {
          title: 'Links',
          items: [
            {label: 'GitHub', href: 'https://github.com/parhumm/jaan-to'},
            {label: 'jaan.to', href: 'https://jaan.to'},
            {
              label: 'The Story',
              href: 'https://medium.com/design-bootcamp/the-smallest-ai-company-that-can-ship-9060938cb28b',
            },
          ],
        },
        {
          title: 'Creator',
          items: [
            {label: 'LinkedIn', href: 'https://www.linkedin.com/in/parhumm/'},
            {label: 'Medium', href: 'https://medium.com/@parhumm'},
            {label: 'GitHub', href: 'https://github.com/parhumm'},
          ],
        },
      ],
      copyright: `Created by <a href="https://www.linkedin.com/in/parhumm/">Parhum Khoshbakht</a>. All rights reserved.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'yaml', 'json'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
