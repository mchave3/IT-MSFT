import { getSession } from 'next-auth/client';

export default async (req, res) => {
  const session = await getSession({ req });

  if (!session) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  if (req.method === 'POST') {
    const { title, content } = req.body;

    // Remplacez ceci par votre logique de stockage d'articles
    // Par exemple, en utilisant une base de données ou un fichier JSON
    console.log('Creating post:', { title, content });

    return res.status(201).json({ message: 'Post created' });
  } else {
    return res.status(405).json({ message: 'Method not allowed' });
  }
};
