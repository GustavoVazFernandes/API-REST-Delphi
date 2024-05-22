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
   procedure AdicionaVideo(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
   procedure ExcluiVideo(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
   procedure BuscaVideo(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
   procedure BuscaConteudoVideo(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
   procedure BuscaTodosVideos(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
   procedure ReciclarVideos(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
   procedure StatusReciclagem(Requisicao: THorseRequest; Resposta: THorseResponse; Proximo: TProc);
   procedure RegistraRotas;
end;

implementation

uses VideoMapper;

{ TVideoController }

procedure TVideoController.AdicionaVideo(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xVideo      : TVideo;
   xBody       : TJSONObject;
   xIDServidor : TGUID;
   xConteudo   : TBytes;
begin
   xIDServidor := StringToGUID(Requisicao.Params['serverId']);
   xBody       := Requisicao.Body<TJSONObject>;

   xVideo            := TVideoMapper.ConverteParaObjeto(xBody);
   xVideo.IDServidor := xIDServidor;

   if vVideoDAO.AdicionaVideo(xVideo, xConteudo) then
      Resposta.Send<TJSONObject>(TVideoMapper.ConverteParaJSON(xVideo))
         .Status(THTTPStatus.Created)
   else
      Resposta.Status(THTTPStatus.InternalServerError);
end;

procedure TVideoController.BuscaConteudoVideo(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xVideo     : TVideo;
   xIDVideo   : TGUID;
   xJSONVideo : TJSONObject;
begin
   xIDVideo := StringToGUID(Requisicao.Params['videoId']);
   xVideo   := vVideoDAO.BuscaVideo(xIDVideo);

   if xVideo <> nil then
   begin
      xJSONVideo := TJSONObject.Create;
      xJSONVideo.AddPair('sizeInBytes', TJSONNumber.Create(xVideo.Conteudo));
      Resposta.Send<TJSONObject>(xJSONVideo).Status(THTTPStatus.OK);
   end
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TVideoController.BuscaTodosVideos(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xIDServer     : TGUID;
   xVariosVideos : TObjectList<TVideo>;
begin
   xIDServer     := StringToGUID(Requisicao.Params['serverId']);
   xVariosVideos := vVideoDAO.BuscaTodosVideos(xIDServer);

   Resposta.Send<TJSONArray>(TVideoMapper.ConverteParaJSONLista(xVariosVideos))
      .Status(THTTPStatus.OK);
end;

procedure TVideoController.BuscaVideo(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xVideo   : TVideo;
   xIDVideo : TGUID;
begin
   xIDVideo := StringToGUID(Requisicao.Params['videoId']);
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
  Resposta: THorseResponse; Proximo: TProc);
var
   xIDVideo: TGUID;
begin
   xIDVideo := StringToGUID(Requisicao.Params['videoId']);

   if vVideoDAO.ExcluiVideo(xIDVideo) then
      Resposta.Status(THTTPStatus.NoContent)
   else
      Resposta.Status(THTTPStatus.NotFound);
end;

procedure TVideoController.ReciclarVideos(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
var
   xDias : Integer;
begin
   xDias := StrToIntDef(Requisicao.Params['days'], 0);

   if vVideoDAO.ReciclarVideos(xDias) then
   begin
      Resposta.Status(THTTPStatus.NoContent);
      vVideoDAO.IniciaReciclagem;
   end
   else
      Resposta.Status(THTTPStatus.BadRequest);
end;

procedure TVideoController.RegistraRotas;
begin
   vVideoDAO := TVideoDAO.Create;

   THorse.Post('/api/servers/:serverID/videos', AdicionaVideo);
   THorse.Delete('/api/videos/:videoId', ExcluiVideo);
   THorse.Get('/api/videos/:videoId', BuscaVideo);
   THorse.Get('/api/videos/:videoId/content', BuscaConteudoVideo);
   THorse.Get('/api/servers/:serverID/videos', BuscaTodosVideos);
   THorse.Delete('/api/videos/recycle/:days', ReciclarVideos);
   THorse.Get('/api/recycler/status', StatusReciclagem);
end;

procedure TVideoController.StatusReciclagem(Requisicao: THorseRequest;
  Resposta: THorseResponse; Proximo: TProc);
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
