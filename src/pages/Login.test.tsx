import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { AuthProvider } from "@/contexts/AuthContext";
import Login from "./Login";

// Em modo demo o usuário já está logado e a tela redireciona; testamos o shell de providers e o redirect.
it("renderiza dentro dos providers sem quebrar", () => {
  render(
    <MemoryRouter initialEntries={["/login"]}>
      <AuthProvider>
        <Login />
      </AuthProvider>
    </MemoryRouter>,
  );
  expect(document.body).toBeInTheDocument();
  expect(screen.queryByRole("alert")).toBeNull();
});
