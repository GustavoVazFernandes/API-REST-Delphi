unit VideoBO;

interface

uses
   Video, System.Generics.Collections, System.SysUtils, System.IOUtils;

type
   TStatusReciclagem = (rsNotRunning, rsRunning);

type
   TVideoBO = Class
   private
      vVideos : TObjectList<TVideo>;
      vStatusReciclagem : TStatusReciclagem;

   public
      constructor Create;
      destructor Destroy; override;
      function AdicionaVideo (Video : TVideo; Conteudo: TBytes) : Boolean;
      function ExcluiVideo (IDVideo : TGUID) : Boolean;
      function BuscaVideo (IDVideo : TGUID) : TVideo;
      function BuscaTodosVideos (IDServidor : TGUID) : TObjectList<TVideo>;
      function ReciclarVideos (Dias : Integer) : Boolean;
      function BuscaStatusReciclagem : TStatusReciclagem;
      procedure IniciaReciclagem;
      procedure FimReciclagem;

end;

implementation

const
   VIDEO_PATH = 'video\';

{ TVideoBO }

function TVideoBO.AdicionaVideo(Video: TVideo; Conteudo: TBytes): Boolean;
var
   xCaminhoArquivo : string;
begin
   xCaminhoArquivo := TPath.Combine(VIDEO_PATH, Video.ID.ToString + '.bin');
   TFile.WriteAllBytes(xCaminhoArquivo, Conteudo);
   vVideos.Add(Video);
   Result := True;
end;

function TVideoBO.BuscaStatusReciclagem: TStatusReciclagem;
begin
   Result := vStatusReciclagem;
end;

function TVideoBO.BuscaTodosVideos(IDServidor: TGUID): TObjectList<TVideo>;
var
  xVideo: TVideo;
  xListaVideo : TObjectList<TVideo>;
begin
   Result := nil;
   xListaVideo  := TObjectList<TVideo>.Create;
   
   for xVideo in vVideos do    
   begin
     if xVideo.IDServidor = IDServidor then
       xListaVideo.Add(xVideo);
   end;
   
   Result := xListaVideo;
end;

function TVideoBO.BuscaVideo(IDVideo: TGUID): TVideo;
var
   xVideo : TVideo;
begin
   Result := nil;

   for xVideo in vVideos do
   begin
      if xVideo.ID = IDVideo then
      begin
         Result := xVideo;
         Exit;
      end;
   end;
end;

constructor TVideoBO.Create;
begin
   vVideos := TObjectList<TVideo>.Create;
   vStatusReciclagem := rsNotRunning;

   if not DirectoryExists(VIDEO_PATH) then
      CreateDir(VIDEO_PATH);
end;

destructor TVideoBO.Destroy;
begin
   vVideos.Free;
   inherited;
end;

function TVideoBO.ExcluiVideo(IDVideo: TGUID): Boolean;
var
   xVideo : TVideo;
   xCaminhoArquivo : string;
begin
   Result := False;
   xVideo := BuscaVideo(IDVideo);

   if xVideo <> nil then
   begin
      xCaminhoArquivo := TPath.Combine(VIDEO_PATH, xVideo.ID.ToString + '.bin');
      
      if TFile.Exists(xCaminhoArquivo) then
         TFile.Delete(xCaminhoArquivo);

      vVideos.Remove(xVideo);
      Result := True;
   end;
end;
 
procedure TVideoBO.FimReciclagem;
begin
   vStatusReciclagem := rsNotRunning;
end;

procedure TVideoBO.IniciaReciclagem;
begin
   vStatusReciclagem := rsRunning;
end;

function TVideoBO.ReciclarVideos(Dias: Integer): Boolean;
var
   xVideo: TVideo;
   xCaminhoArquivo: string;
   xDataLimite: TDateTime;
begin
   xDataLimite := Now - Dias;
   IniciaReciclagem;

   for xVideo in vVideos do
   begin
      xCaminhoArquivo :=TPath.Combine(VIDEO_PATH, xVideo.ID.ToString + '.bin');
      if FileAge(xCaminhoArquivo) < xDataLimite then
      begin
         TFile.Delete(xCaminhoArquivo);
         vVideos.Remove(xVideo);
         FimReciclagem;
      end;
   end;
   Result := True;
end;

end.
