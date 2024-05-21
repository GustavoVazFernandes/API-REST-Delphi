program API;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.Commons,
  Horse.Exception,
  Servidor in 'models\Servidor.pas',
  Video in 'models\Video.pas',
  ServidorBO in 'models\ServidorBO.pas',
  VideoBO in 'models\VideoBO.pas',
  ServidorDAO in 'models\ServidorDAO.pas',
  VideoDAO in 'models\VideoDAO.pas',
  ServidorController in 'Controller\ServidorController.pas',
  VideoController in 'Controller\VideoController.pas',
  ServidorMapper in 'mappers\ServidorMapper.pas';

var
   vServidorController : TServidorController;
   vVideoController    : TVideoController;

begin
   THorse.Use(Jhonson());

   vServidorController := TServidorController.Create;
   vServidorController.RegistraRotas;

   vVideoController := TVideoController.Create;
   vVideoController.RegistraRotas;

   THorse.Listen(9000);
end.

