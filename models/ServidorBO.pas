unit ServidorBO;

interface

uses
   Servidor, System.Generics.Collections, System.SysUtils, System.JSON;

type
   TServidorBO = Class
   private
      vServidores : TObjectList<TServidor>;

   public
      constructor Create;
      destructor Destroy; override;
      function AdicionaServidor(Servidor: TServidor): Boolean;
      function AtualizaServidor(Servidor: TServidor): Boolean;
      function RemoveServidor  (IDServidor: TGUID): Boolean;
      function BuscaServidor   (IDServidor: TGUID) : TServidor;
      function BuscaVariosServidores : TObjectList<TServidor>;

end;

implementation



{ TServidorBO }

function TServidorBO.AdicionaServidor(Servidor: TServidor): Boolean;
begin
   vServidores.Add(Servidor);
   Result := True;
end;

function TServidorBO.AtualizaServidor(Servidor: TServidor): Boolean;
var
   xExisteServidor : TServidor;
begin
   xExisteServidor := BuscaServidor(Servidor.ID);

   if xExisteServidor <> nil then
   begin
      xExisteServidor.Nome  := Servidor.Nome;
      xExisteServidor.IP    := Servidor.IP;
      xExisteServidor.Porta := Servidor.Porta;
      Result                := True;
   end
   else
      Result := False;
end;

function TServidorBO.BuscaServidor(IDServidor: TGUID): TServidor;
var
   xServidor : TServidor;
begin
   Result := nil;

   for xServidor in vServidores do
   begin
      if xServidor.ID = IDServidor then
      begin
         Result := xServidor;
         Exit;
      end;
   end;
end;

function TServidorBO.BuscaVariosServidores: TObjectList<TServidor>;
begin
   Result := vServidores;
end;

constructor TServidorBO.Create;
begin
   vServidores := TObjectList<TServidor>.Create;
end;

destructor TServidorBO.Destroy;
begin
  vServidores.Free;
  inherited;
end;

function TServidorBO.RemoveServidor(IDServidor: TGUID): Boolean;
var
   xServidor : TServidor;
begin
   xServidor := nil;
   xServidor := BuscaServidor(IDServidor);

   if xServidor <> nil then
   begin
      vServidores.Remove(xServidor);
      Result := True;
   end
   else
      Result := False;
end;

end.
