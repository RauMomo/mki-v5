// Path: ./config/env/production/server.js`
export default ({ env }) => ({
  proxy: true,
  url: env("https://limitless-crag-37749-01d18c8df6e5.herokuapp.com/"), // Sets the public URL of the application.
  app: {
    keys: env.array("APP_KEYS"),
  },
});
