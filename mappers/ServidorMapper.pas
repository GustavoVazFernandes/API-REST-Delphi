unit ServidorMapper;

interface

uses  Horse, Servidor, System.JSON, System.SysUtils, System.Generics.Collections;

type
   TServidorMapper = Class
   private

   public
   class function ConverteParaJSON (Servidor : TServidor) : TJSONObject;
   class function ConverteParaJSONLista (ListaServidores : TObjectList<TServidor>) : TJSONArray;
   class function ConverteParaObjeto (Body : TJSONObject) : TServidor;
end;

implementation

{ TServidorMapper }

class function TServidorMapper.ConverteParaJSON(
  Servidor: TServidor): TJSONObject;
begin
     Result := TJSONObject.Create;
     Result.AddPair('id', Servidor.ID.ToString);
     Result.AddPair('name', Servidor.Nome);
     Result.AddPair('ip', Servidor.IP);
     Result.AddPair('port', TJSONNumber.Create(Servidor.Porta));
end;

class function TServidorMapper.ConverteParaJSONLista(
  ListaServidores: TObjectList<TServidor>): TJSONArray;
var
   xServidor: TServidor;
begin
   Result := TJSONArray.Create;

   for xServidor in ListaServidores do
   begin
      Result.AddElement(TServidorMapper.ConverteParaJSON(xServidor));
   end;
end;

class function TServidorMapper.ConverteParaObjeto(Body: TJSONObject): TServidor;

begin
   Result := TServidor.Create;

   Result.ID := TGUID.NewGuid;

   Result.Nome := Body.GetValue<string>('name', '');
   Result.IP := Body.GetValue<string>('ip', '');
   Result.Porta := Body.GetValue<Integer>('port',-1);

   if Result.Nome = '' then
      FreeAndNil(Result)
   else
   if Result.IP = '' then
      FreeAndNil(Result)
   else
   if Result.Porta = -1 then
      FreeAndNil(Result)






end;

end.
