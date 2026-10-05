import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
export default function NaoEncontrado() {
  return (
    <div className="grid min-h-screen place-items-center p-6 text-center">
      <div className="space-y-3">
        <h1 className="text-2xl font-bold">Página não encontrada</h1>
        <Button asChild><Link to="/">Voltar ao início</Link></Button>
      </div>
    </div>
  );
}
