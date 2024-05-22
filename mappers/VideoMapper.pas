unit VideoMapper;

interface

uses  Horse, Video, System.JSON, System.SysUtils, System.Generics.Collections,
   System.NetEncoding;

type
   TVideoMapper = Class
   private

   public
      class function ConverteParaJSON (Video : TVideo) : TJSONObject;
      class function ConverteParaJSONLista (ListaVideos : TObjectList<TVideo>) : TJSONArray;
      class function ConverteParaObjeto (Body : TJSONObject) : TVideo;

end;

implementation

{ TVideoMapper }

class function TVideoMapper.ConverteParaJSON(Video: TVideo): TJSONObject;
begin
    Result := TJSONObject.Create;

    Result.AddPair('id', Video.ID.ToString);
    Result.AddPair('description', Video.Descricao);
    Result.AddPair('sizeInBytes', TJSONNumber.Create(Video.Conteudo));
    Result.AddPair('serverId', Video.IDServidor.ToString);
end;

class function TVideoMapper.ConverteParaJSONLista(
  ListaVideos: TObjectList<TVideo>): TJSONArray;
var
   xVideo : TVideo;
begin
   Result := TJSONArray.Create;

   for xVideo in ListaVideos do
   begin
      Result.AddElement(TVideoMapper.ConverteParaJSON(xVideo));
   end;
end;

class function TVideoMapper.ConverteParaObjeto(Body: TJSONObject): TVideo;
begin
   Result           := TVideo.Create;
   Result.ID        := TGUID.NewGuid;
   Result.Descricao := Body.GetValue<string>('description', '');
   Result.Conteudo  := Body.GetValue<Integer>('sizeInBytes', -1);

   if Result.Descricao = '' then
      FreeAndNil(Result)
   else
   if Result.Conteudo = -1 then
      FreeAndNil(Result)
   
end;

end.
