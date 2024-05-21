unit ServidorDAO;

interface

uses
   Servidor, ServidorBO, System.Generics.Collections;

type
   TServidorDAO = Class
   private
      vServidorBO : TServidorBO;

   public
      constructor Create;
      function CriaServidor(Servidor: TServidor): Boolean;
      function AtualizaServidor(Servidor: TServidor): Boolean;
      function ExcluiServidor(IDServidor: TGUID): Boolean;
      function BuscaServidor(IDServidor: TGUID): TServidor;
      function BuscaTodosServidores: TObjectList<TServidor>;
end;

implementation

{ TServidorDAO }

function TServidorDAO.BuscaServidor(IDServidor: TGUID): TServidor;
begin
   Result := vServidorBO.BuscaServidor(IDServidor);
end;

function TServidorDAO.BuscaTodosServidores: TObjectList<TServidor>;
begin
   Result := vServidorBO.BuscaVariosServidores;
end;

constructor TServidorDAO.Create;
begin
   vServidorBO := TServidorBO.Create;
end;

function TServidorDAO.CriaServidor(Servidor: TServidor): Boolean;
begin
   Result := vServidorBO.AdicionaServidor(Servidor);
end;

function TServidorDAO.ExcluiServidor(IDServidor: TGUID): Boolean;
begin
   Result := vServidorBO.RemoveServidor(IDServidor);
end;

function TServidorDAO.AtualizaServidor(Servidor: TServidor): Boolean;
begin
   Result := vServidorBO.AtualizaServidor(Servidor);
end;

end.
