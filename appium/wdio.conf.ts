import type { Options } from '@wdio/types';

export const config: Options.Testrunner = {
  runner: 'local',
  autoCompileOpts: {
    autoCompile: true,
    tsNodeOpts: {
      project: './tsconfig.json',
      transpileOnly: true,
    },
  },

  port: 4723,
  path: '/',

  specs: ['./tests/**/*.test.ts'],

  exclude: [],

  maxInstances: 1,

  capabilities: [
    {
      platformName: 'iOS',
      'appium:automationName': 'XCUITest',
      'appium:deviceName': process.env.DEVICE_NAME || undefined,
      'appium:platformVersion': process.env.IOS_VERSION || undefined,
      'appium:app':
        process.env.GOALS_APP_PATH ||
        '/tmp/rallyops-derived-data/Build/Products/Release-iphonesimulator/rallyops.app',
      'appium:noReset': false,
      'appium:fullReset': false,
      'appium:wdaLaunchTimeout': 180000,
      'appium:wdaStartupRetryInterval': 30000,
    },
  ],

  logLevel: 'info',

  bail: 0,

  baseUrl: '',

  waitforTimeout: 30000,

  connectionRetryTimeout: 300000,

  connectionRetryCount: 5,

  services: [
    [
      'appium',
      {
        command: 'appium',
        args: {
          relaxedSecurity: true,
        },
      },
    ],
  ],

  framework: 'mocha',

  reporters: [
    ['spec', {}],
    [
      'junit',
      {
        outputDir: './test-results',
        outputFileFormat: function (options: any) {
          return `results-${options.cid}.xml`;
        },
      },
    ],
  ],

  mochaOpts: {
    ui: 'bdd',
    timeout: 60000,
  },
};
