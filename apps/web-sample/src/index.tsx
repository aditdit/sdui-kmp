import React, { useMemo } from 'react';
import ReactDOM from 'react-dom/client';
import { SduiParser } from 'shared';
import { SDUIRenderer } from 'react-web-sdui';

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('Failed to find the root element');

const App = () => {
  const parser = useMemo(() => new SduiParser(), []);
  const mockJson = parser.getMockData();
  const components = parser.parseAsArray(mockJson);

  return (
    <div style={{ padding: '20px' }}>
      <h1>SDUI Modula Web Sample</h1>
      <SDUIRenderer components={components} />
    </div>
  );
};

ReactDOM.createRoot(rootElement).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);