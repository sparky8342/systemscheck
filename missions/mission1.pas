program Mission1;

{$mode objfpc}

uses
  SysUtils, StrUtils;

function getinput : TStringArray;
const
  C_FNAME = '../inputs/1.txt';
var
  tfIn: TextFile;
  line_no : Integer = 0;
begin
  AssignFile(tfIn, C_FNAME);
  result := TStringArray.Create;
  SetLength(result, 1);
  try
    reset(tfIn);
    while not eof(tfIn) do
    begin
      if Length(result) < line_no + 1 then
        SetLength(result, Length(result) * 2);
      Readln(tfIn, result[line_no]);
      line_no := line_no + 1;
    end;
    CloseFile(tfIn);
    SetLength(result, line_no);
  except
    on E: EInOutError do
     writeln('File handling error occurred. Details: ', E.Message);
  end;
end;

var
  disabled_count : Integer = 0;
  max_time : Integer = 0;
  max_disabled_count : Integer = 0;
  max_disabled_time : Integer = 0;
  i, reactor, time, disabled_time, time_diff : Integer;
  data : TStringArray = ('');
  parts : TStringArray;
  reactor_times : Array of Integer = ();

begin
  data := getinput();
  for i := 0 to Length(data) - 1 do
  begin
      parts := SplitString(data[i], ' ');
      time := StrToInt(copy(parts[0], 3));
      reactor := StrToInt(copy(parts[1], 2));

      if parts[2] = 'disabled' then
        begin
          if Length(reactor_times) < reactor then
            SetLength(reactor_times, reactor);
          reactor_times[reactor] := time;

          disabled_count := disabled_count + 1;
          disabled_time := time;
        end
      else if parts[2] = 'enabled' then
        begin
          time_diff := time - reactor_times[reactor];
	  if time_diff > max_time then
            max_time := time_diff;

          if disabled_count > max_disabled_count then
            begin
              max_disabled_count := disabled_count;
              max_disabled_time := time - disabled_time;
            end
          else if disabled_count = max_disabled_count then
            begin
              time_diff := time - disabled_time;
              if time_diff > max_disabled_time then
                max_disabled_time := time_diff
            end;

          disabled_count := disabled_count - 1;
        end;
    end;

  writeln(max_time);
  writeln(max_disabled_time);
end.
