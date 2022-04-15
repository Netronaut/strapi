module.exports = ({ env }) => ({
  auth: {
    secret: env('ADMIN_JWT_SECRET', '2ebebd1170aec9e66cf900a18ac2ce41'),
  },
});
