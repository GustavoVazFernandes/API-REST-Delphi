unit VideoDAO;

interface

uses
   Video, VideoBO, System.Generics.Collections, System.SysUtils;

type
   TStatusReciclagem = (rsNotRunning, rsRunning);

type
   TVideoDAO = Class
   private
      vVideoBO : TVideoBO;
      vStatusReciclagem : TStatusReciclagem;

   public
      constructor Create;
      function AdicionaVideo      (Video : TVideo; Conteudo : TBytes) : Boolean;
      function ExcluiVideo        (IDVideo : TGUID) : Boolean;
      function BuscaConteudoVideo (IDVideo : TGUID) : TBytes;
      function BuscaTodosVideos   (IDServidor : TGUID) : TObjectList<TVideo>;
      function ReciclarVideos     (Dias : Integer) : Boolean;
      function BuscaVideo         (IDVideo : TGUID) : TVideo;
      function BuscaStatusReciclagem: TStatusReciclagem;
      procedure IniciaReciclagem;

end;

implementation

{ TVideoDAO }

function TVideoDAO.AdicionaVideo(Video: TVideo; Conteudo: TBytes): Boolean;
begin
   Result := vVideoBO.AdicionaVideo(Video, Conteudo);
end;

function TVideoDAO.BuscaConteudoVideo(IDVideo: TGUID): TBytes;
begin
   Result := vVideoBO.BuscaConteudoVideo(IDVideo);
end;

function TVideoDAO.BuscaStatusReciclagem: TStatusReciclagem;
begin
   Result := vStatusReciclagem;
end;

function TVideoDAO.BuscaTodosVideos(IDServidor: TGUID): TObjectList<TVideo>;
begin
   Result := vVideoBO.BuscaTodosVideos(IDServidor);
end;

function TVideoDAO.BuscaVideo(IDVideo: TGUID): TVideo;
begin
   Result := vVideoBO.BuscaVideo(IDVideo);
end;

constructor TVideoDAO.Create;
begin
   vVideoBO := TVideoBO.Create;
   vStatusReciclagem := rsNotRunning;
end;

function TVideoDAO.ExcluiVideo(IDVideo: TGUID): Boolean;
begin
   Result := vVideoBO.ExcluiVideo(IDVideo);
end;

procedure TVideoDAO.IniciaReciclagem;
begin
   vStatusReciclagem := rsRunning;
end;

function TVideoDAO.ReciclarVideos(Dias: Integer): Boolean;
begin
   Result := vVideoBO.ReciclarVideos(Dias);
end;

end.
