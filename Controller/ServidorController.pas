unit ServidorController;

interface

uses
   Horse, ServidorDAO, ServidorBO, Servidor, System.SysUtils, System.JSON,
   Horse.Jhonson, System.Generics.Collections;

type
   TServidorController = Class
   private
      vServidorDAO : TServidorDAO;

   public
      procedure RegistraRotas;
      procedure CriaServidor (Requisicao: THorseRequest; Resposta: THorseResponse);
      procedure AtualizaServidor (Requisicao: THorseRequest; Resposta: THorseResponse);
      procedure ExcluiServidor (Requisicao: THorseRequest; Resposta: THorseResponse);
      procedure BuscaServidor (Requisicao: THorseRequest; Resposta: THorseResponse);
      procedure BuscaTodosServidores (Requisicao: THorseRequest; Resposta: THorseResponse);
      procedure BuscaStatusServidor (Requisicao: THorseRequest; Resposta: THorseResponse);

end;

implementation

uses
   ServidorMapper;

{ TServidorController }

procedure TServidorController.AtualizaServidor(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xServidor   : TServidor;
   xBody       : TJSONObject;
   xIDServidor : TGUID;
begin
   try
      xIDServidor := StringToGUID(Requisicao.Params['serverId']);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;

   xServidor   := vServidorDAO.BuscaServidor(xIDServidor);

   if xServidor <> nil then
   begin
      xBody           := Requisicao.Body<TJSONObject>;
      xServidor.Nome  := xBody.GetValue<string>('name', '');
      xServidor.IP    := xBody.GetValue<string>('ip', '');
      xServidor.Porta := xBody.GetValue<Integer>('port',0);

      if vServidorDAO.AtualizaServidor(xServidor) then
         Resposta.Send<TJSONObject>(TServidorMapper.ConverteParaJSON(xServidor))
            .Status(THTTPStatus.OK)
      else
         Resposta.Status(THTTPStatus.InternalServerError);
   end
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TServidorController.BuscaServidor(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xServidor     : TServidor;
   xIDServidor   : TGUID;
begin
   try
      xIDServidor := StringToGUID(Requisicao.Params['serverId']);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;

   xServidor   := vServidorDAO.BuscaServidor(xIDServidor);

   if xServidor <> nil then
   begin
      Resposta.Send<TJSONObject>(TServidorMapper.ConverteParaJSON(xServidor))
         .Status(THTTPStatus.OK);
   end
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TServidorController.BuscaStatusServidor(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xJSONStatus : TJSONObject;
   xServidor   : TServidor;
   xIDServidor   : TGUID;
begin
   try
      xIDServidor := StringToGUID(Requisicao.Params['serverId']);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;

   xServidor   := vServidorDAO.BuscaServidor(xIDServidor);
   xJSONStatus := TJSONObject.Create;

   if xServidor <> nil then
   begin
      if vServidorDAO.BuscaStatusServidor(xIDServidor) = Disponivel then
         xJSONStatus.AddPair('status', 'Disponivel')
      else
         xJSONStatus.AddPair('status', 'Indisponivel');
         Resposta.Send<TJSONObject>(xJSONStatus).Status(THTTPStatus.OK);
   end
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TServidorController.BuscaTodosServidores(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xServidores: TObjectList<TServidor>;
begin
   xServidores := vServidorDAO.BuscaTodosServidores;

   Resposta.Send<TJSONArray>(TServidorMapper.ConverteParaJSONLista(xServidores))
      .Status(THTTPStatus.OK);
end;

procedure TServidorController.CriaServidor(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xServidor : TServidor;
   xBody     : TJSONObject;
begin
   xBody     := Requisicao.Body<TJSONObject>;
   xServidor := TServidorMapper.ConverteParaObjeto(xBody);

   if xServidor = nil then
   begin
      Resposta.Status(THTTPStatus.BadRequest);
      Exit;
   end;

   if vServidorDAO.CriaServidor(xServidor) then
      Resposta.Send<TJSONObject>(TServidorMapper.ConverteParaJSON(xServidor))
         .Status(THTTPStatus.Created)
   else
      Resposta.Status(THTTPStatus.InternalServerError);
end;

procedure TServidorController.ExcluiServidor(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xIDServidor : TGUID;
begin
    try
      xIDServidor := StringToGUID(Requisicao.Params['serverId']);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;

    if vServidorDAO.ExcluiServidor(xIDServidor) then
       Resposta.Status(THTTPStatus.NoContent)
    else
       Resposta.Status(THTTPStatus.NotFound);
end;

procedure TServidorController.RegistraRotas;
begin
   vServidorDAO := TServidorDAO.Create;

   THorse.Post('/api/server', CriaServidor);
   THorse.Put('/api/servers/:serverId', AtualizaServidor);
   THorse.Delete('/api/servers/:serverId', ExcluiServidor);
   THorse.Get('/api/servers/:serverId', BuscaServidor);
   THorse.Get('/api/servers', BuscaTodosServidores);
   THorse.Get('/api/servers/available/:serverId', BuscaStatusServidor)
end;

end.
