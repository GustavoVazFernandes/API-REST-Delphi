unit Video;

interface

uses
   System.SysUtils;

type
   TVideo = Class
   private
      vID         : TGUID;
      vDescricao  : String;
      vConteudo   : Int64;
      vIDServidor : TGUID;

   public
    property ID         :TGUID  read vID         write vID;
    property Descricao  :string read vDescricao  write vDescricao;
    property Conteudo   :Int64  read vConteudo   write vConteudo;
    property IDServidor :TGUID  read vIDServidor write vIDServidor;

end;


implementation

end.
