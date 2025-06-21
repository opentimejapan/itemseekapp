import './globals.css';

export const metadata = {
  title: 'Tasks App',
  description: 'Task management for hotel operations',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
      </head>
      <body>{children}</body>
    </html>
  )
}
