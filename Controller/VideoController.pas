unit VideoController;

interface

uses
   Horse, VideoBO, Video,VideoDAO, System.SysUtils, System.JSON, System.Classes,
   System.NetEncoding, System.Generics.Collections;

type
   TVideoController = Class
   private
   vVideoDAO : TVideoDAO;

   public
   procedure AdicionaVideo (Requisicao: THorseRequest; Resposta: THorseResponse);
   procedure ExcluiVideo(Requisicao: THorseRequest; Resposta: THorseResponse);
   procedure BuscaVideo(Requisicao: THorseRequest; Resposta: THorseResponse);
   procedure BuscaConteudoVideo(Requisicao: THorseRequest; Resposta: THorseResponse);
   procedure BuscaTodosVideos(Requisicao: THorseRequest; Resposta: THorseResponse);
   procedure ReciclarVideos(Requisicao: THorseRequest; Resposta: THorseResponse);
   procedure StatusReciclagem(Requisicao: THorseRequest; Resposta: THorseResponse);
   procedure RegistraRotas;
end;

implementation

uses VideoMapper;

{ TVideoController }

procedure TVideoController.AdicionaVideo(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xVideo      : TVideo;
   xBody       : TJSONObject;
   xIDServidor : TGUID;
   xConteudo   : TBytes;
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

   xBody := Requisicao.Body<TJSONObject>;
   xVideo := TVideoMapper.ConverteParaObjeto(xBody, xIDServidor);

   if xVideo = nil then
   begin
      Resposta.Status(THTTPStatus.BadRequest);
      Exit;
   end;

   if vVideoDAO.AdicionaVideo(xVideo, xConteudo) then
      Resposta.Send<TJSONObject>(TVideoMapper.ConverteParaJSON(xVideo))
         .Status(THTTPStatus.Created)
   else
      Resposta.Status(THTTPStatus.InternalServerError);
end;

procedure TVideoController.BuscaConteudoVideo(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xVideoBytes: TBytes;
   xIDVideo   : string;
   xStream    : TFileStream;
begin
   try
      xIDVideo := (Requisicao.Params['videoId']);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;

   xStream := TFileStream.Create(ExtractFilePath('video\') + xIDVideo + '.bin', fmOpenRead);
   if xStream <> nil then
      Resposta.Send<TStream>(xStream).Status(THTTPStatus.OK)
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TVideoController.BuscaTodosVideos(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xIDServidor     : TGUID;
   xVariosVideos : TObjectList<TVideo>;
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

   xVariosVideos := vVideoDAO.BuscaTodosVideos(xIDServidor);
   Resposta.Send<TJSONArray>(TVideoMapper.ConverteParaJSONLista(xVariosVideos))
      .Status(THTTPStatus.OK);
end;

procedure TVideoController.BuscaVideo(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xVideo      : TVideo;
   xIDVideo    : TGUID;
   xIDServidor : TGUID;
begin
   try
      xIDVideo    := StringToGUID(Requisicao.Params['videoId']);
      xIDServidor := StringToGUID(Requisicao.Params['serverId']);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;

   xVideo   := vVideoDAO.BuscaVideo(xIDVideo);

   if xVideo <> nil then
   begin
      Resposta.Send<TJSONObject>(TVideoMapper.ConverteParaJSON(xVideo))
         .Status(THTTPStatus.OK);
   end
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TVideoController.ExcluiVideo(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xIDVideo: TGUID;
   xIDServidor: TGUID;
begin
   try
      xIDVideo    := StringToGUID(Requisicao.Params['videoId']);
      xIDServidor := StringToGUID(Requisicao.Params['serverId']);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;


   if vVideoDAO.ExcluiVideo(xIDVideo) then
      Resposta.Status(THTTPStatus.NoContent)
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TVideoController.ReciclarVideos(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xDias : Integer;
begin
   try
      xDias := StrToIntDef(Requisicao.Params['days'], 0);
   except
      on E: Exception do
      begin
         Resposta.Status(THTTPStatus.BadRequest);
         Exit;
      end;
   end;

   if vVideoDAO.ReciclarVideos(xDias) then
   begin
      Resposta.Status(THTTPStatus.NoContent);
   end
   else
      Resposta.Status(THTTPStatus.BadRequest);
end;

procedure TVideoController.RegistraRotas;
begin
   vVideoDAO := TVideoDAO.Create;

   THorse.Post('/api/servers/:serverID/videos', AdicionaVideo);
   THorse.Delete('/api/servers/:serverId/videos/:videoId', ExcluiVideo);
   THorse.Get('/api/servers/:serverId/videos/:videoId', BuscaVideo);
   THorse.Get('/api/servers/:serverId/videos/:videoId/binary', BuscaConteudoVideo);
   THorse.Get('/api/servers/:serverID/videos', BuscaTodosVideos);
   THorse.Delete('/api/videos/recycle/:days', ReciclarVideos);
   THorse.Get('/api/recycler/status', StatusReciclagem);
end;

procedure TVideoController.StatusReciclagem(Requisicao: THorseRequest;
  Resposta: THorseResponse);
var
   xJSONStatus : TJSONObject;
begin
   xJSONStatus := TJSONObject.Create;

   if vVideoDAO.BuscaStatusReciclagem = rsRunning then
      xJSONStatus.AddPair('status', 'running')
   else
      xJSONStatus.AddPair('status', 'not running');
      Resposta.Send<TJSONObject>(xJSONStatus).Status(THTTPStatus.OK);
end;

end.
