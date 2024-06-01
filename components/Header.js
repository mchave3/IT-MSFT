import Link from 'next/link';

const Header = () => (
  <header>
    <nav>
      <ul>
        <li><Link href="/"><a>Home</a></Link></li>
        <li><Link href="/about"><a>About</a></Link></li>
        <li><Link href="/blog"><a>Blog</a></Link></li>
      </ul>
    </nav>
  </header>
);

export default Header;
