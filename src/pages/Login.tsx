import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { Navigate } from "react-router-dom";
import { appConfig } from "../../app.config";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const schema = z.object({ email: z.string().email("E-mail inválido"), senha: z.string().min(6, "Mínimo 6 caracteres") });
type Form = z.infer<typeof schema>;

export default function Login() {
  const { usuario, entrarComEmail } = useAuth();
  const [erro, setErro] = useState<string | null>(null);
  const { register, handleSubmit, formState } = useForm<Form>({ resolver: zodResolver(schema) });
  if (usuario) return <Navigate to="/" replace />;

  const enviar = handleSubmit(async (d) => setErro(await entrarComEmail(d.email, d.senha)));

  return (
    <div className="grid min-h-screen place-items-center p-4">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>{appConfig.nome}</CardTitle>
          <CardDescription>{appConfig.descricao}</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={enviar} className="space-y-4" noValidate>
            <div className="space-y-1.5">
              <Label htmlFor="email">E-mail</Label>
              <Input id="email" type="email" autoComplete="email" {...register("email")} />
              {formState.errors.email && <p className="text-xs text-destructive">{formState.errors.email.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="senha">Senha</Label>
              <Input id="senha" type="password" autoComplete="current-password" {...register("senha")} />
              {formState.errors.senha && <p className="text-xs text-destructive">{formState.errors.senha.message}</p>}
            </div>
            {erro && <p className="text-sm text-destructive" role="alert">{erro}</p>}
            <Button type="submit" className="w-full" disabled={formState.isSubmitting}>Entrar</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
