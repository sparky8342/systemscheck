program Mission1;

{$mode objfpc}

uses
  SysUtils, StrUtils;

const
  C_FNAME = '../inputs/1.txt';

var
  tfIn: TextFile;
  data : Array of String = ('', '');
  line_no : integer = 0;
  i: Integer;
  reactor : Integer;
  parts : TStringArray;
  reactor_times : Array of Integer = ();
  time : Integer;
  max_time : Integer = 0;

begin
  AssignFile(tfIn, C_FNAME);
  try
    reset(tfIn);
    while not eof(tfIn) do
    begin
      if Length(data) < line_no + 1 then
        SetLength(data, Length(data) * 2);
      Readln(tfIn, data[line_no]);
      line_no := line_no + 1;
    end;
    CloseFile(tfIn);
  except
    on E: EInOutError do
     writeln('File handling error occurred. Details: ', E.Message);
  end;

  for i := 0 to line_no - 1 do
  begin
      parts := SplitString(data[i], ' ');
      time := StrToInt(copy(parts[0], 3));
      reactor := StrToInt(copy(parts[1], 2));

      if parts[2] = 'disabled' then
        begin
          if Length(reactor_times) < reactor then
            SetLength(reactor_times, reactor);
          reactor_times[reactor] := time;
        end
      else if parts[2] = 'enabled' then
        begin
          time := time - reactor_times[reactor];
	  if time > max_time then
            max_time := time;
        end;
  end;

  writeln(max_time);
end.
