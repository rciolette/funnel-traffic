import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App";
import { ErrorBoundary } from "@/components/erros/ErrorBoundary";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <ErrorBoundary nivel="tela" nome="tela">
      <App />
    </ErrorBoundary>
  </StrictMode>,
);
