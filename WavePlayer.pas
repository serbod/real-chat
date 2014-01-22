//This file introduces a class that is able to play waves and mpeg1 audio from
//resource, memory and disk via TStream class. It uses WAVE_MAPPER instead
//of PlaySound, so that you can play waves simultaneously.

//Copyright(c) 2001-2003 by Ing. Tomas Koutny. (rawos@rawos.com, xdtktom@quick.cz)
//Version 2.11

//------------------------------------------------------------------------------
//WARRANTIES AND DISCLAIMER:
//
//EXCEPT AS EXPRESSLY PROVIDED OTHERWISE IN A WRITTEN AGREEMENT BETWEEN
//Tomas Koutny ("LICENSOR") AND YOU, THE LICENSED WORKS ARE NOW PROVIDED "AS IS"
//WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT
//LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
//FOR A PARTICULAR PURPOSE, OR THE WARRANTY OF NON-INFRINGEMENT.

//IN NO EVENT SHALL LICENSOR OR ITS SUPPLIERS BE LIABLE TO YOU OR ANY THIRD
//PARTY FOR ANY SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
//KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING, WITHOUT LIMITATION, THOSE
//RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER OR NOT LICENSOR HAD BEEN
//ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, AND ON ANY THEORY OF LIABILITY,
//ARISING OUT OF OR IN CONNECTION WITH THE USE OF THE LICENSED WORKS. SOME
//JURISDICTIONS PROHIBIT THE EXCLUSION OR LIMITATION OF LIABILITY FOR
//CONSEQUENTIAL OR INCIDENTAL DAMAGES, SO THE ABOVE LIMITATIONS MAY NOT APPLY TO
//YOU. THESE LIMITATIONS SHALL APPLY NOTWITHSTANDING ANY FAILURE OF ESSENTIAL
//PURPOSE OF ANY LIMITED REMEDY.
//------------------------------------------------------------------------------

//See www.rawos.com for more software and resources.

//
// Remarks
// =======
//
// * Some audio codecs allow only one decoding process per application.
// * To play MPEG audio you need to have already installed appropriate codec,
//

(*
 * Version History:
 *
 * Version 2.11
 *
 * * Fixed the window procedure to handle all messages.
 *
 * Version 2.1
 *
 * * Fixed closing of the device by replacing callback procedure with window
 *   one. However you should consider to create a separate thread for feeding
 *   the buffers if you plan to do something more complicated.
 *   Very special thanks to Steve Timms <Steve@play-time.demon.co.uk>
 *   for finding this bug and proposed solution.
 *
 * Version 2.01
 *
 * + Added OnFinishedPlayback property being invoked when the playback has
 *   finished without the Stop command
 *
 * Version 2.0
 *
 * + Now able to play MPEG1 audio directly via audio codec (for XP&higher only)
 *   (This is experimental now)
 * + Now able to play MPEG1 Layer III independently on XP and higher
 * - BlocksInBuffer is no more used as each buffer is being computed
 *   to last 0.015625 of sec
 *
 * Version 1.7
 *
 * + Chunks after 'data' one are no longer being played
 *   => No more strange sounds if 'data' chunk is not the last one.
 *
 * Version 1.6
 *
 * + TWavePlayer.Stop no longer waits for infinity with sleep
 *
 * Version 1.5
 *
 * + Playback functions were made virtual including constructor
 * + New class TFakeWavePlayer to produce sound when TWavePlayer crashes
 *
 * Version 1.0
 *
 * + fixed bugs related to the playback stopping
 * + now able to play via synchronyous device
 *
 * Version 0.94
 *
 * + fixed bugs, which occurred in stop and destructor 
 *
 * Version 0.93
 *
 * + now can beep on Play in case of failure
 * + fixed for configurations, which are able to play only one sound
 *   simultaneously
 *
 * Version 0.92
 * + fixed cbSize treatment with PCM wavs loading
 *
 * Version 0.91
 * + new properties to control the count of loops to be played
 * = properties Stream and Loop were made published
 *
 * Version 0.9
 * * Initial release
 *)

unit WavePlayer;

interface

uses Classes, Windows, MMSystem, Messages;


type
  TWavePlayingState = (wpStopped, wpPlaying, wpPaused, wpDone);

  TCallbackCatcher = class(TThread)
  end;

  TWavePlayer = class(TThread)
  private
    FDevice:HWAVEOUT;                //Device to play the wave
    FBuffers:array[0..7] of TWAVEHDR;//8 buffers to have not chopping playback
    FBufferSize:integer;             //How much memory to allocate per buffer
    FRepeat:boolean;                 //Whether to play in a loop
    FDataStart:integer;              //Where the headers end
    FDataEnd:integer;                //Length of data (+1 to avoid one asm add
                                     //in LoadBuffer) ; data chunk is not
                                     //always the last one
    FPlayingBufferCount:integer;     //Number of buffers being played
    procedure LoadBuffer(AIndex:integer);  //Loads values into selected buffer
    function LoadWaveFile:PWaveFormatEx;
    function LoadMPEG1File:PWaveFormatEx;
    procedure waveOutProc(hwo: HWAVEOUT; uMsg: UINT; dwInstance, dwParam1, dwParam2: DWORD_PTR); stdcall;
  protected
    FState:TWavePlayingState;  //Internal (and desired) state
    FSource:TStream;           //Source the wave will be played from
        //Following two variables may be figured out by setting FRepeat to true
    FLoopsToPlay:integer;      //Remaining count of loops to be played
    FDesiredLoops:integer;     //Desired count of loops to be played
    FBeepAtLeast:boolean;
    FOnFinishedPlayback:TNotifyEvent;
    FWnd:HWND;
    procedure MsgHandler(var msg:TMessage);
    //procedure Dispatch(var msg:TMessage); override;
    procedure Execute(); override;
  public
    LastMsg: TMessage;
    constructor Create;
    destructor Destroy; override;

    //All functions below return true if they proceed successfuly
    //and false if not.
    function Play:boolean;  virtual;     //Starts or unpauses the wave playing
    function Stop:boolean;  virtual;    //Stops the current wave playing
    function Reset:boolean; virtual;    //Rewinds to zero and stops playing
    function Pause:boolean; virtual;    //Pauses or unpauses the wave playing

    property State:TWavePlayingState read FState;
  published
    //The Source property MUST be set before the wave playing is started!
    //(The riff file format uses 32 bit adressing => the standard stream
    // is sufficient.)
    property Source:TStream read FSource write FSource;
     //The Loop property should be also set before the wave playing is started,
    //because all internal buffers are being queued regardless of this value.
    property Loop:boolean read FRepeat write FRepeat;

    property Loops:integer read FDesiredLoops write FDesiredLoops;

    property BeepAtLeast:boolean read FBeepAtLeast write FBeepAtLeast;
    property OnFinishedPlayback:TNotifyEvent read FOnFinishedPlayback
                                             write FOnFinishedPlayback;
  end;

  TFakeWaveMode = (none,            //No faking at all; default
                   message,         //MessageBeep(MB_OK)
                   speaker,         //System beep via speaker
                   silence);        //No playback will ever occur

  TFakeWavePlayer = class(TWavePlayer)
  protected
    FFakeMode:TFakeWaveMode;
    FOddPause:boolean;  //Needed to simulate un/pausing
  public
    constructor Create;

    function Play:boolean;  override;
    function Stop:boolean;  override;
    function Reset:boolean; override;
    function Pause:boolean; override;
  published
    property FakeMode:TFakeWaveMode read FFakeMode write FFakeMode;
        //NEVER CHANGE DURING A PLAYBACK!!!
  end;

implementation

uses SysUtils, Forms;

const
  { - Eliminated
  BlocksInBuffer = 2048000; //How much blocks will be in one buffer - now
                         //0.0116 of a second in the PCM uncompressed mode.
                         //Small value makes playing chopping, the big one
                         //makes play stopping hard.
  }

  WaveHdrSize = sizeof(TWAVEHDR); //Why to call sizeof so much times?

//Declare the wave file header's structure
type
  TWAVHeader = packed record
    RIFFHeader: packed array [0..3] of Char;   //'RIFF'
    FileSize: Longint;
    WAVEHeader: packed array [0..3] of Char;   //'WAVE'
    FormatHeader: packed array [0..3] of Char; //'fmt ' - there's a space!
    FormatSize: Longint;
    FormatEx:TWaveFormatEx;
  end;

  TChunk = packed record
    Signature:LongWord;
    Length:longint;
  end;

  //Since the support of MPEG1
  //Following is taken from MSDN Library
  PMPEG1WAVEFORMAT = ^TMPEG1WAVEFORMAT;
  TMPEG1WAVEFORMAT = packed record
    wfx:TWaveFormatEx;
    fwHeadLayer:word;
    dwHeadBitrate:DWORD;
    fwHeadMode:WORD;
    fwHeadModeExt:WORD;
    wHeadEmphasis:WORD;
    fwHeadFlags:WORD;
    dwPTSLow:DWORD;
    dwPTSHigh:DWORD;
  end;

  PMPEGLAYER3WAVEFORMAT = ^TMPEGLAYER3WAVEFORMAT;
  TMPEGLAYER3WAVEFORMAT = packed record
    wfx:tWAVEFORMATEX;
    wID:WORD;
    fdwFlags:DWORD;
    nBlockSize:WORD;
    nFramesPerBlock:WORD;
    nCodecDelay:WORD;
  end;


const
  WAVE_FORMAT_MPEG = $50;
  WAVE_FORMAT_MPEGLAYER3 = $55;

  ACM_MPEG_LAYER1  = 1;
  ACM_MPEG_LAYER2  = 2;
  ACM_MPEG_LAYER3  = 4;

  ACM_MPEG_STEREO        = 1;
  ACM_MPEG_JOINTSTEREO   = 2;
  ACM_MPEG_DUALCHANNEL   = 4;
  ACM_MPEG_SINGLECHANNEL = 8;

  ACM_MPEG_ID_MPEG1 = $10;
  MPEGLAYER3_ID_MPEG = 1;

  MPEGLAYER3_FLAG_PADDING_ON  = 1;
  MPEGLAYER3_FLAG_PADDING_OFF = 2;




type
  EWPlayer = Exception;

//--------------------------------------------------------------- Class' methods

constructor TWavePlayer.Create();
begin
  inherited Create(true);
  FState:=wpStopped;
  FRepeat:=false;
  BeepAtLeast:=false;
  //FWnd:=AllocateHWnd(MsgHandler);
end;

destructor TWavePlayer.Destroy();
begin
  try
    Stop();
  finally
    //DeallocateHWnd(FWnd);
  end;

  inherited;
end;

procedure TWavePlayer.waveOutProc(hwo: HWAVEOUT; uMsg: UINT; dwInstance, dwParam1, dwParam2: DWORD_PTR); stdcall;
var
  wp: TWavePlayer;
begin
  if uMsg = WOM_DONE then
  begin
    wp:=TWavePlayer(dwInstance);
    wp.LastMsg.Msg:=MM_WOM_DONE;
    wp.LastMsg.WParam:=hwo;
    wp.LastMsg.LParam:=dwParam1;
  end;
end;

procedure TWavePlayer.Execute();
begin
  if LastMsg.Msg = MM_WOM_DONE then
  begin
    Application.MessageBox(PChar('1'), PChar('2'));
    MsgHandler(LastMsg);
    LastMsg.Msg:=0;
  end;
end;

procedure TWavePlayer.MsgHandler(var msg:TMessage);
var i:integer;
begin
  with Msg do
    case Msg of
      //MM_WOM_CLOSE: exit;//No reason to do something here
      MM_WOM_DONE:
      begin
        //Using hwo is faster than FDevice since it is in a register
        waveOutUnprepareHeader(wParam,
                               PWAVEHDR(lParam),
                               WaveHdrSize);
        dec(FPlayingBufferCount);

        if FState = wpStopped then
        begin
          if FPlayingBufferCount <= 0 then FState:=wpDone;
          Exit;
        end;
           //Presume that stopping is in progress

        //Get data
        LoadBuffer(PWAVEHDR(lParam)^.dwUser);

        //Check for end of wave
        if PWAVEHDR(lParam)^.dwBufferLength = 0 then
        begin
          if FRepeat or (FLoopsToPlay>0) then  //Play once again or not?
          begin
            FSource.Position:=FDataStart;
            LoadBuffer(PWAVEHDR(lParam)^.dwUser);
            waveOutWrite(wParam, PWAVEHDR(lParam), WaveHdrSize);
            dec(FLoopsToPlay);
            if FLoopsToPlay<0 then FLoopsToPlay:=0;
          end
          else
          begin
            if FPlayingBufferCount<1 then
            begin
              //No more data to play => properly end the playback
              FState:=wpStopped;
              waveOutReset(wParam); //it may hang up without this
              waveOutClose(wParam);//Some devices are able to play
                               //only one sound=>close it
                               //and hope that only one sound
                               //is desired to be played
              for i:=0 to 7 do
                freemem(FBuffers[i].lpData);

              FState:=wpDone;
              //Call the event as last to ensure that we've
              //done everything in case that event rises
              //some exception
              if Assigned(FOnFinishedPlayback) then
                FOnFinishedPlayback(Self);
            end;
          end;
        end
        else
          waveOutWrite(wParam, PWAVEHDR(lParam), WaveHdrSize);
      end;
    //MM_WOM_OPEN:exit;  //Nothing to play so soon
    else
       Result:=DefWindowProc(FWnd, msg, wParam, lParam);
    end;
end;

procedure TWavePlayer.LoadBuffer(AIndex:integer);
var LoadableBufferSize:integer;
begin
  with FBuffers[AIndex], FSource do
    begin
      dwFlags:=0;

      LoadableBufferSize:=FDataEnd-Position-FBufferSize;
      if LoadableBufferSize>=0 then LoadableBufferSize:=FBufferSize
        else inc(LoadableBufferSize, FBufferSize);

      dwBufferLength:=Read(lpData^, LoadableBufferSize);
      if dwBufferLength = 0 then exit; //no data to be played

      if waveOutPrepareHeader(FDevice, @FBuffers[AIndex], WaveHdrSize) =
         MMSYSERR_NOERROR then inc(FPlayingBufferCount);
    end;
end;

function TWavePlayer.LoadWaveFile:PWaveFormatEx;
var WaveHdr:TWAVHeader;
    chunk:TChunk;
begin
  result:=nil;
  try
    FSource.Position:=0;
    FSource.ReadBuffer(WaveHdr, sizeof(TWAVHeader));

    //OK, the we got the header now test it
    if WaveHdr.WAVEHeader <> 'WAVE' then Abort;

    //We're gonna process wave file

    //check for PCM files
    with WaveHdr.FormatEx do
      if wFormatTag = WAVE_FORMAT_PCM then
         begin
           cbSize:=0; //sanity assignment
           FSource.Position:=WaveHdr.FormatSize+20;
                //Some programs takes cbSize as a header member and some don't,
                //but all programs (I've seen) fills FormatSize correctly
         end;

    getmem(result, WaveHdr.FormatEx.cbSize+sizeof(TWaveFormatEx));
    result^:=WaveHdr.FormatEx;

    //And load the rest of format dependent data if any
    FSource.ReadBuffer(pointer(Cardinal(result)+sizeof(TWaveFormatEx))^,
                       result^.cbSize);

    //Skip all chunks, that we're not interested in
    FSource.ReadBuffer(chunk, sizeof(chunk));
    while chunk.Signature <> $61746164 do //<> 'data'
      begin
        FSource.position:=FSource.position+chunk.Length; //seek doesn't work
        FSource.ReadBuffer(chunk, sizeof(chunk));
      end;

    //Remember the file island of the 'data' chunk
    FDataStart:=FSource.position;
    FDataEnd:=FDataStart+chunk.Length;
  except
    if result<>nil then FreeAndNil(result);
  end;
end;

function TWavePlayer.LoadMPEG1File:PWaveFormatEx;

const
  bufSize = 4096;
  SamplingFreq:array[0..3] of integer = (44100, 48000, 32000, 0);

  ACM_Channels:array[0..3] of integer = (ACM_MPEG_STEREO,
                                         ACM_MPEG_JOINTSTEREO,
                                         ACM_MPEG_DUALCHANNEL,
                                         ACM_MPEG_SINGLECHANNEL);

  ACM_Layers:array[1..3] of integer = (ACM_MPEG_LAYER1,
                                       ACM_MPEG_LAYER2,
                                       ACM_MPEG_LAYER3); 

  bitrates:array[0..2, 0..15] of integer = (
                    (0,32,64,96,128,160,192,224,256,288,320,352,384,416,448, 0),
                    (0,32,48,56,64,80,96,112,128,160,192,224,256,320,384, 0),
                    (0,32,40,48,56,64,80,96,112,128,160,192,224,256,320, 0));
        //Note that the bad combination will produce 0 'cause we've scanned
        //only one frame



var i, j:integer;
    buf:PByteArray;
    frame:DWORD;       //Sure, it's only the header
    isLayer3:boolean;

begin
  result:=nil;
  frame:=0;
  buf:=nil;
  try
    //Search for synchronization flag of first frame
    FSource.Position:=0;
    try
      getmem(buf, bufSize);
      repeat
        FDataStart:=FSource.Position;
        j:=FSource.Read(buf^, bufSize);
        for i:=0 to j-5 do
          if (buf^[i] = $FF) and
             (buf^[i+1] and $F0 = $F0) and
             (buf^[i+1] and 6 <> 0) then
             //OK, it looks like frame we are looking for
             begin
               frame:=PDWORD(longint(buf)+i)^;
               FDataStart:=FDataStart+i;
               j:=0;
               break;
             end;
        if j<>0 then FSource.Seek(-3, soFromCurrent);
      until j = 0;
    finally
      if buf<>nil then freemem(buf);
    end;

    //If no frame has been found then it is not MPEG1
    if frame = 0 then Abort;

    //Layer I & II are supported by WXP and higher DShow
    isLayer3:=(frame shr 13) and 3 = 3;

    //Fill the wave info

    //Use more supported way if possible
    if isLayer3 then getmem(result, sizeof(TMPEGLAYER3WAVEFORMAT))
      else getmem(result, sizeof(TMPEG1WAVEFORMAT));
    with result^ do
      begin
        if isLayer3 then wFormatTag:=WAVE_FORMAT_MPEGLAYER3
          else wFormatTag:=WAVE_FORMAT_MPEG;
           //3 means mono, else it is stereo
        if (frame shr 30) and 3 = 3 then nChannels:=1
          else nChannels:=2;
        nSamplesPerSec:=SamplingFreq[(frame shr 18) and 3];

        nAvgBytesPerSec:=bitrates[((frame shr 13) and 3)-1,
                                  (frame shr 20) and $f]*1000 shr 3;
        nBlockAlign:=1;
        wBitsPerSample:=0;
        if isLayer3 then cbSize:=sizeof(TMPEGLAYER3WAVEFORMAT)-sizeof(TWAVEFORMATEX)
          else cbSize:=sizeof(TMPEG1WAVEFORMAT)-sizeof(TWAVEFORMATEX);
      end;

      if isLayer3 then
        with PMPEGLAYER3WAVEFORMAT(result)^ do
          begin
            wID:=MPEGLAYER3_ID_MPEG;

            if frame and $20000 <> 0 then fdwFlags:=MPEGLAYER3_FLAG_PADDING_ON
              else fdwFlags:=MPEGLAYER3_FLAG_PADDING_OFF;

            //We have to take care about frequency to be accurate
            with wfx do
              if nSamplesPerSec>=32000 then
                nBlockSize:=1152*nAvgBytesPerSec div nSamplesPerSec
                else nBlockSize:=576*nAvgBytesPerSec div nSamplesPerSec;

            nFramesPerBlock:=1;
            nCodecDelay:=$0571;//If you're interested in this value then search
                               //e.g. for FHG in LAME's sources.
          end else
            with PMPEG1WAVEFORMAT(result)^ do
              begin
                fwHeadLayer:=ACM_Layers[(frame shr 13) and 3];
                dwHeadBitrate:=bitrates[((frame shr 13) and 3)-1,
                                        (frame shr 20) and $f];
                fwHeadMode:=ACM_Channels[(frame shr 30) and 3];
                fwHeadModeExt:=0;     //For encoding and we're player only
                wHeadEmphasis:=((frame shr 24) and 3)+1;
                dwPTSLow:=0;
                dwPTSHigh:=0;
                fwHeadFlags:=ACM_MPEG_ID_MPEG1;
              end;


    FDataEnd:=FSource.Size;
    //MPEG uses synchronization bits, so we can "safely" pass end of source
  except
    if result<>nil then FreeAndNil(result);
  end;
end;


function TWavePlayer.Play(): boolean;
var WaveInfo:PWaveFormatEx;
    i:integer;
    res:MMRESULT;

begin
  //There can be a case instead of this 2 ifs, but the compiler will optimize it

  if FState = wpPlaying then
    begin
      result:=false;
      exit;
    end;

  //Check for unpause
  if FState = wpPaused then
    begin
      result:=Pause;
      exit;
    end;

  Self.Resume();

  //if anything will go wrong, then an exception will arise
  WaveInfo:=nil; //keeps compiler quiet
  try
    WaveInfo:=LoadWaveFile();
    if WaveInfo = nil then WaveInfo:=LoadMPEG1File;
    if WaveInfo = nil then Abort;

    FLoopsToPlay:=FDesiredLoops-1; //One loop will be always played
    FPlayingBufferCount:=0;        //None is actually being played

    //Allocate Buffers
    //with WaveInfo^ do FBufferSize:=nBlockAlign*nSamplesPerSec shr 6; //Like div 64
    with WaveInfo^ do FBufferSize:=nBlockAlign*nAvgBytesPerSec; //Like div 64
                //BlocksInBuffer;
    for i:=0 to 7 do
      begin
        getmem(FBuffers[i].lpData, FBufferSize);
        FBuffers[i].dwLoops:=1;
        FBuffers[i].dwUser:=i;
      end;

    //Open the WAVE_MAPPER,
//    res:=waveOutOpen(@FDevice, WAVE_MAPPER, WaveInfo,
//                     FWnd,
//                     cardinal(Self),
//                     CALLBACK_WINDOW or WAVE_ALLOWSYNC);
    res:=waveOutOpen(@FDevice, WAVE_MAPPER, WaveInfo,
                     Cardinal(@TWavePlayer.waveOutProc),
                     cardinal(Self),
                     CALLBACK_FUNCTION or WAVE_ALLOWSYNC);
    if res <> MMSYSERR_NOERROR then
        raise EWPlayer.Create('MM System Error: '+inttostr(res));
    freemem(WaveInfo);

    //Seek the first data byte
    FSource.Position:=FDataStart;
    //load buffers
    for i:=0 to 7 do
      LoadBuffer(i);

    //and play them.
    FState:=wpPlaying; //Mark desired state
    for i:=0 to 7 do
      if FBuffers[i].dwBufferLength <> 0 then
         waveOutWrite(FDevice, @FBuffers[i], WaveHdrSize);

    result:=true;
  except
    FState:=wpStopped;

    freemem(WaveInfo);
    for i:=0 to 7 do
      freemem(FBuffers[i].lpData);
    result:=false;

    if FBeepAtLeast then Windows.MessageBeep(MB_ICONQUESTION);

    FState:=wpStopped;
  end;
end;

function TWavePlayer.Stop(): boolean;
var i:integer;
begin
  result:=false;

  if FState = wpStopped then exit;

  try
    //if not Reset then Abort;  //This call sets FState to wpStopped
    FState:=wpStopped; //This will stop loading the buffers

    Self.Suspend();

    //Actually a call to waveOutReset should be here, but it always hangs up
    //current thread => try to close the device right now

    if waveOutClose(FDevice) <> MMSYSERR_NOERROR then
      //Successfull waveOutClose sends WOM_DONE for all buffers
      //=>waveOutProc unprepares and frees them
      begin
        //OK, we can still try to stop the playback without any reset

        for i:=0 to 7 do
          FBuffers[i].dwBufferLength:=0;

        i:=16;   //Countdown - Forever Is Long Long Time
        while (FPlayingBufferCount>0) and (i>0) do
          begin
            Sleep(100);
            dec(i);
          end;

        if waveOutClose(FDevice) <> MMSYSERR_NOERROR then Abort;

        //Because we've waited with demand to immediately stop loading buffers,
        //we've to release them manualy
        for i:=0 to 7 do
          freemem(FBuffers[i].lpData);
      end;

    result:=true;
  except
  end;
end;

function TWavePlayer.Reset(): boolean;
begin
  try
    FState:=wpStopped; //--This will at least stop loading the buffers
    if waveOutReset(FDevice) <> MMSYSERR_NOERROR then Abort;

    result:=true;
  except
    result:=false;
  end;
end;

function TWavePlayer.Pause(): boolean;
begin
  try
    case FState of
      wpStopped:Abort;
      wpPlaying:begin
                  FState:=wpPaused; //Mark desired state
                  if waveOutPause(FDevice) <> MMSYSERR_NOERROR then Abort;
                end;
      wpPaused: begin
                  FState:=wpPlaying; //Mark desired state
                  if waveOutRestart(FDevice) <> MMSYSERR_NOERROR then Abort;
                end;
    end;
    result:=true;
  except
    result:=false;
  end;
end;

//---------------------------------------------------------------TFakeWavePlayer

constructor TFakeWavePlayer.Create;
begin
  inherited;

  FFakeMode:=none;
  FOddPause:=false;
end;

function TFakeWavePlayer.Play:boolean;
begin
  result:=true;  //Anything else then none has to return true
  case FFakeMode of
    none:       result:=inherited Play;
    message     :MessageBeep(MB_OK);
    speaker     :MessageBeep($FFFFFFFF);
    //none:     OK, so let's be silent
  end;
end;

function TFakeWavePlayer.Stop:boolean;
begin
  if FFakeMode = none then result:=inherited Stop
    else result:=true;
end;

function TFakeWavePlayer.Reset:boolean;
begin
  if FFakeMode = none then result:=inherited Reset
    else result:=true;
end;

function TFakeWavePlayer.Pause:boolean;
begin
  if FFakeMode = none then result:=inherited Pause
    else begin
      FOddPause:=not FOddPause;
      if FOddPause then result:=Play
        else result:=true;
    end

end;

end.
