import NextAuth from 'next-auth';
import Providers from 'next-auth/providers';

export default NextAuth({
  providers: [
    Providers.Credentials({
      // Add your own logic for authenticating the user
      authorize: async (credentials) => {
        const user = { id: 1, name: 'Admin', email: 'admin@example.com' }; // Replace with real user validation
        if (credentials.username === 'admin' && credentials.password === 'password') {
          return user;
        } else {
          return null;
        }
      },
    }),
  ],
  callbacks: {
    async jwt(token, user) {
      if (user) {
        token.id = user.id;
      }
      return token;
    },
    async session(session, token) {
      session.user.id = token.id;
      return session;
    },
  },
  secret: process.env.NEXTAUTH_SECRET,
});
