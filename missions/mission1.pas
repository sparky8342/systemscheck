program Mission1;

{$mode objfpc}

uses
  SysUtils, StrUtils;

const
  C_FNAME = '../inputs/1.txt';

var
  line_no : Integer = 0;
  disabled_count : Integer = 0;
  max_time : Integer = 0;
  max_disabled_count : Integer = 0;
  max_disabled_time : Integer = 0;
  i, reactor, time, disabled_time, time_diff : Integer;
  data : Array of String = ('', '');
  tfIn: TextFile;
  parts : TStringArray;
  reactor_times : Array of Integer = ();

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
