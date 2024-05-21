unit Servidor;

interface

uses
   System.SysUtils;

type
   TServidor = Class
   private
      vID    : TGUID;
      vNome  : String;
      vIP    : String;
      vPorta : Integer;

   public
      property ID    :TGUID   read vID    write vID;
      property Nome  :string  read vNome  write vNome;
      property IP    :string  read vIP    write vIP;
      property Porta :Integer read vPorta write vPorta;
   End;

implementation

end.
