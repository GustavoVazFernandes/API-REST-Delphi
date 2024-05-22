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
      procedure CriaServidor(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
      procedure AtualizaServidor(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
      procedure ExcluiServidor(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
      procedure BuscaServidor(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
      procedure BuscaTodosServidores(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);

end;

implementation

uses
   ServidorMapper;

{ TServidorController }

procedure TServidorController.AtualizaServidor(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xServidor : TServidor;
   xBody : TJSONObject;
   xIDServidor : TGUID;
begin
   xIDServidor := StringToGUID(Requisicao.Params['id']);
   xServidor   := vServidorDAO.BuscaServidor(xIDServidor);

   if xServidor <> nil then
   begin
      xBody := Requisicao.Body<TJSONObject>;
      xServidor.Nome := xBody.GetValue<string>('name', '');
      xServidor.IP := xBody.GetValue<string>('ip', '');
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
  Resposta: THorseResponse; Proximo: TProc);
var
   xJSONServidor : TJSONObject;
   xServidor : TServidor;
   xIDServidor : TGUID;
begin
   xIDServidor := StringToGUID(Requisicao.Params['id']);
   xServidor := vServidorDAO.BuscaServidor(xIDServidor);

   if xServidor <> nil then
   begin
      try
         Resposta.Send<TJSONObject>(TServidorMapper.ConverteParaJSON(xServidor)).Status(THTTPStatus.OK);
      finally
         if xServidor <> nil then
            FreeAndNil(xServidor);
      end;
   end
   else
     Resposta.Status(THTTPStatus.NotFound);
end;

procedure TServidorController.BuscaTodosServidores(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xServidores: TObjectList<TServidor>;
begin
   xServidores := vServidorDAO.BuscaTodosServidores;

   Resposta.Send<TJSONArray>(TServidorMapper.ConverteParaJSONLista(xServidores))
      .Status(THTTPStatus.OK);
end;

procedure TServidorController.CriaServidor(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xServidor : TServidor;
   xBody : TJSONObject;
begin
   xBody := Requisicao.Body<TJSONObject>;
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
  Resposta: THorseResponse; Proximo: TProc);
var
   xIDServidor : TGUID;
begin
    xIDServidor := StringToGUID(Requisicao.Params['id']);

    if vServidorDAO.ExcluiServidor(xIDServidor) then
       Resposta.Status(THTTPStatus.NoContent)
    else
       Resposta.Status(THTTPStatus.NotFound);
end;

procedure TServidorController.RegistraRotas;
begin
   vServidorDAO := TServidorDAO.Create;

   THorse.Post('/api/server', CriaServidor);
   THorse.Put('/api/servers/:id', AtualizaServidor);
   THorse.Delete('/api/servers/:id', ExcluiServidor);
   THorse.Get('/api/servers/:id', BuscaServidor);
   THorse.Get('/api/servers', BuscaTodosServidores);
end;

end.
