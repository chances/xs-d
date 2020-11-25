// Auto-generated. DO NOT EDIT!

/// Bindings to the XS JavaScript Engine <a href="https://github.com/Moddable-OpenSource/moddable/blob/OS201116/documentation/xs/XS%20in%20C.md">C API</a>.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2020 Chance Snow. All rights reserved.
/// License: MIT License
module xs.bindings;

import core.stdc.config;
import core.stdc.stdarg: va_list;
static import core.simd;
static import std.conv;

enum XS_MAJOR_VERSION = 10;
enum XS_MINOR_VERSION = 4;
enum XS_PATCH_VERSION = 0;
enum txS1[4] XS_VERSION = [XS_MAJOR_VERSION, XS_MINOR_VERSION, XS_PATCH_VERSION, 0];

struct Int128 { long lower; long upper; }
struct UInt128 { ulong lower; ulong upper; }

struct __locale_data { int dummy; }  // FIXME

alias _Bool = bool;
struct dpp {
    static struct Opaque(int N) {
        void[N] bytes;
    }
    // Replacement for the gcc/clang intrinsic
    static bool isEmpty(T)() {
        return T.tupleof.length == 0;
    }
    static struct Move(T) {
        T* ptr;
    }
    // dmd bug causes a crash if T is passed by value.
    // Works fine with ldc.
    static auto move(T)(ref T value) {
        return Move!T(&value);
    }
    mixin template EnumD(string name, T, string prefix) if(is(T == enum)) {
        private static string _memberMixinStr(string member) {
            import std.conv: text;
            import std.array: replace;
            return text(`    `, member.replace(prefix, ""), ` = `, T.stringof, `.`, member, `,`);
        }
        private static string _enumMixinStr() {
            import std.array: join;
            string[] ret;
            ret ~= "enum " ~ name ~ "{";
            static foreach(member; __traits(allMembers, T)) {
                ret ~= _memberMixinStr(member);
            }
            ret ~= "}";
            return ret.join("\n");
        }
        mixin(_enumMixinStr());
    }
}

extern(C)
{
    struct __sigset_t
    {
        c_ulong[16] __val;
    }
    alias __jmp_buf = c_long[8];
    void siglongjmp(__jmp_buf_tag*, int) @nogc nothrow;
    alias sigjmp_buf = __jmp_buf_tag[1];
    void _longjmp(__jmp_buf_tag*, int) @nogc nothrow;
    void longjmp(__jmp_buf_tag*, int) @nogc nothrow;
    int _setjmp(__jmp_buf_tag*) @nogc nothrow;
    int __sigsetjmp(__jmp_buf_tag*, int) @nogc nothrow;
    int setjmp(__jmp_buf_tag*) @nogc nothrow;
    alias jmp_buf = __jmp_buf_tag[1];
    struct __jmp_buf_tag
    {
        c_long[8] __jmpbuf;
        int __mask_was_saved;
        __sigset_t __saved_mask;
    }
    int* __errno_location() @nogc nothrow;
    void fxAbort(xsMachineRecord*, int) @nogc nothrow;
    int fxMatchRegExp(xsMachineRecord*, int*, int*, char*, int) @nogc nothrow;
    void fxDeleteRegExp(xsMachineRecord*, int*, int*) @nogc nothrow;
    int fxCompileRegExp(xsMachineRecord*, char*, char*, int**, int**, char*, int) @nogc nothrow;
    void fxAwaitImport(xsMachineRecord*, int) @nogc nothrow;
    void fxUnmapArchive(void*) @nogc nothrow;
    void* fxMapArchive(const(ubyte)*, c_ulong, char*, void function(xsMachineRecord*) function(short)) @nogc nothrow;
    void fxStopProfiling(xsMachineRecord*) @nogc nothrow;
    void fxStartProfiling(xsMachineRecord*) @nogc nothrow;
    int fxIsProfiling(xsMachineRecord*) @nogc nothrow;
    void* fxMarshall(xsMachineRecord*, int) @nogc nothrow;
    void fxDemarshall(xsMachineRecord*, void*, int) @nogc nothrow;
    double fxStringToNumber(xsMachineRecord*, char*, ubyte) @nogc nothrow;
    char* fxNumberToString(xsMachineRecord*, double, char*, int, char, int) @nogc nothrow;
    char* fxIntegerToString(xsMachineRecord*, int, char*, int) @nogc nothrow;
    int fxUnicodeToUTF8Offset(char*, int) @nogc nothrow;
    int fxUnicodeLength(char*) @nogc nothrow;
    int fxUTF8ToUnicodeOffset(char*, int) @nogc nothrow;
    int fxUTF8Length(int) @nogc nothrow;
    char* fxUTF8Encode(char*, int) @nogc nothrow;
    char* fxUTF8Decode(char*, int*) @nogc nothrow;
    void fxEncodeURI(xsMachineRecord*, char*) @nogc nothrow;
    void fxDecodeURI(xsMachineRecord*, char*) @nogc nothrow;
    void fxAccess(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxForget(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxRemember(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void* fxRenewChunk(xsMachineRecord*, void*, int) @nogc nothrow;
    void* fxNewChunk(xsMachineRecord*, int) @nogc nothrow;
    xsSlotRecord* fxDuplicateSlot(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxEnableGarbageCollection(xsMachineRecord*, int) @nogc nothrow;
    void fxCollectGarbage(xsMachineRecord*) @nogc nothrow;
    void fxEndHost(xsMachineRecord*) @nogc nothrow;
    xsMachineRecord* fxBeginHost(xsMachineRecord*) @nogc nothrow;
    void fxShareMachine(xsMachineRecord*) @nogc nothrow;
    xsMachineRecord* fxPrepareMachine(xsCreationRecord*, void*, char*, void*, void*) @nogc nothrow;
    xsMachineRecord* fxCloneMachine(xsCreationRecord*, xsMachineRecord*, char*, void*) @nogc nothrow;
    void fxDeleteMachine(xsMachineRecord*) @nogc nothrow;
    xsMachineRecord* fxCreateMachine(xsCreationRecord*, char*, void*) @nogc nothrow;
    void fxReport(xsMachineRecord*, char*, ...) @nogc nothrow;
    void fxDebugger(xsMachineRecord*, char*, int) @nogc nothrow;
    void fxBubble(xsMachineRecord*, int, void*, int, char*) @nogc nothrow;
    void fxThrowMessage(xsMachineRecord*, char*, int, int, char*) @nogc nothrow;
    void fxThrow(xsMachineRecord*, char*, int) @nogc nothrow;
    void fxOverflow(xsMachineRecord*, int, char*, int) @nogc nothrow;
    int fxCheckVar(xsMachineRecord*, int) @nogc nothrow;
    int fxCheckArg(xsMachineRecord*, int) @nogc nothrow;
    void fxVars(xsMachineRecord*, int) @nogc nothrow;
    int fxRunTest(xsMachineRecord*) @nogc nothrow;
    void fxRunCount(xsMachineRecord*, int) @nogc nothrow;
    void fxNewID(xsMachineRecord*, int) @nogc nothrow;
    void fxNew(xsMachineRecord*) @nogc nothrow;
    void fxCallID(xsMachineRecord*, int) @nogc nothrow;
    void fxCall(xsMachineRecord*) @nogc nothrow;
    void fxDeleteID(xsMachineRecord*, int) @nogc nothrow;
    void fxDeleteAt(xsMachineRecord*) @nogc nothrow;
    void fxDefineID(xsMachineRecord*, int, ubyte, ubyte) @nogc nothrow;
    void fxDefineAt(xsMachineRecord*, ubyte, ubyte) @nogc nothrow;
    void fxSetID(xsMachineRecord*, int) @nogc nothrow;
    void fxSetAt(xsMachineRecord*) @nogc nothrow;
    void fxSet(xsMachineRecord*, xsSlotRecord*, int) @nogc nothrow;
    void fxGetID(xsMachineRecord*, int) @nogc nothrow;
    void fxGetAt(xsMachineRecord*) @nogc nothrow;
    void fxGet(xsMachineRecord*, xsSlotRecord*, int) @nogc nothrow;
    int fxHasID(xsMachineRecord*, int) @nogc nothrow;
    int fxHasAt(xsMachineRecord*) @nogc nothrow;
    void fxEnumerate(xsMachineRecord*) @nogc nothrow;
    char* fxName(xsMachineRecord*, short) @nogc nothrow;
    short fxToID(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    int fxIsID(xsMachineRecord*, char*) @nogc nothrow;
    short fxFindID(xsMachineRecord*, char*) @nogc nothrow;
    short fxID(xsMachineRecord*, const(char)*) @nogc nothrow;
    void fxSetHostHooks(xsMachineRecord*, xsSlotRecord*, const(xsHostHooksStruct)*) @nogc nothrow;
    xsHostHooksStruct* fxGetHostHooks(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void* fxGetHostHandle(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxSetHostDestructor(xsMachineRecord*, xsSlotRecord*, void function(void*)) @nogc nothrow;
    void function(void*) fxGetHostDestructor(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxSetHostData(xsMachineRecord*, xsSlotRecord*, void*) @nogc nothrow;
    void* fxGetHostData(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void* fxSetHostChunk(xsMachineRecord*, xsSlotRecord*, void*, int) @nogc nothrow;
    void* fxGetHostChunk(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    xsSlotRecord* fxNewHostObject(xsMachineRecord*, void function(void*)) @nogc nothrow;
    void fxNewHostInstance(xsMachineRecord*) @nogc nothrow;
    void fxNewHostFunction(xsMachineRecord*, void function(xsMachineRecord*), int, int) @nogc nothrow;
    void fxNewHostConstructor(xsMachineRecord*, void function(xsMachineRecord*), int, int) @nogc nothrow;
    void fxBuildHosts(xsMachineRecord*, int, xsHostBuilderRecord*) @nogc nothrow;
    void fxArrayCacheItem(xsMachineRecord*, xsSlotRecord*, xsSlotRecord*) @nogc nothrow;
    void fxArrayCacheEnd(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxArrayCacheBegin(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    int fxIsInstanceOf(xsMachineRecord*) @nogc nothrow;
    xsSlotRecord* fxNewObject(xsMachineRecord*) @nogc nothrow;
    xsSlotRecord* fxNewArray(xsMachineRecord*, int) @nogc nothrow;
    xsSlotRecord* fxToReference(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxReference(xsMachineRecord*, xsSlotRecord*, xsSlotRecord*) @nogc nothrow;
    xsSlotRecord* fxToClosure(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxClosure(xsMachineRecord*, xsSlotRecord*, xsSlotRecord*) @nogc nothrow;
    void* fxToArrayBuffer(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxSetArrayBufferLength(xsMachineRecord*, xsSlotRecord*, int) @nogc nothrow;
    void fxSetArrayBufferData(xsMachineRecord*, xsSlotRecord*, int, void*, int) @nogc nothrow;
    int fxGetArrayBufferLength(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxGetArrayBufferData(xsMachineRecord*, xsSlotRecord*, int, void*, int) @nogc nothrow;
    void fxArrayBuffer(xsMachineRecord*, xsSlotRecord*, void*, int) @nogc nothrow;
    uint fxToUnsigned(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    alias txS1 = byte;
    alias txU1 = ubyte;
    alias txS2 = short;
    alias txU2 = ushort;
    alias txS4 = int;
    alias txU4 = uint;
    void fxUnsigned(xsMachineRecord*, xsSlotRecord*, uint) @nogc nothrow;
    char* fxToStringX(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    char* fxToStringBuffer(xsMachineRecord*, xsSlotRecord*, char*, int) @nogc nothrow;
    char* fxToString(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    alias xsCreation = xsCreationRecord;
    struct xsCreationRecord
    {
        int initialChunkSize;
        int incrementalChunkSize;
        int initialHeapCount;
        int incrementalHeapCount;
        int stackCount;
        int keyCount;
        int nameModulo;
        int symbolModulo;
        int parserBufferSize;
        int parserTableModulo;
        int staticSize;
    }
    alias xsJump = xsJumpRecord;
    struct xsJumpRecord
    {
        __jmp_buf_tag[1] buffer;
        xsJumpRecord* nextJump;
        xsSlotRecord* stack;
        xsSlotRecord* scope_;
        xsSlotRecord* frame;
        xsSlotRecord* environment;
        short* code;
        int flag;
    }
    alias xsMachine = xsMachineRecord;
    struct xsMachineRecord
    {
        xsSlotRecord* stack;
        xsSlotRecord* scope_;
        xsSlotRecord* frame;
        short* code;
        xsSlotRecord* stackBottom;
        xsSlotRecord* stackTop;
        xsSlotRecord* stackPrototypes;
        xsJumpRecord* firstJump;
        void* context;
        void* archive;
        xsSlotRecord scratch;
    }
    alias xsSlot = xsSlotRecord;
    struct xsSlotRecord
    {
        void*[4] data;
    }
    alias xsHostBuilder = xsHostBuilderRecord;
    struct xsHostBuilderRecord
    {
        void function(xsMachineRecord*) callback;
        short length;
        short id;
    }
    alias xsHostHooks = xsHostHooksStruct;
    struct xsHostHooksStruct
    {
        void function(void*) destructor;
        void function(xsMachineRecord*, void*, void function(xsMachineRecord*, xsSlotRecord*)) marker;
        void function(xsMachineRecord*, void*, void function(xsMachineRecord*, xsSlotRecord*)) sweeper;
    }
    enum _Anonymous_0
    {
        xsUndefinedType = 0,
        xsNullType = 1,
        xsBooleanType = 2,
        xsIntegerType = 3,
        xsNumberType = 4,
        xsStringType = 5,
        xsStringXType = 6,
        xsSymbolType = 7,
        xsBigIntType = 8,
        xsBigIntXType = 9,
        xsReferenceType = 10,
    }
    enum xsUndefinedType = _Anonymous_0.xsUndefinedType;
    enum xsNullType = _Anonymous_0.xsNullType;
    enum xsBooleanType = _Anonymous_0.xsBooleanType;
    enum xsIntegerType = _Anonymous_0.xsIntegerType;
    enum xsNumberType = _Anonymous_0.xsNumberType;
    enum xsStringType = _Anonymous_0.xsStringType;
    enum xsStringXType = _Anonymous_0.xsStringXType;
    enum xsSymbolType = _Anonymous_0.xsSymbolType;
    enum xsBigIntType = _Anonymous_0.xsBigIntType;
    enum xsBigIntXType = _Anonymous_0.xsBigIntXType;
    enum xsReferenceType = _Anonymous_0.xsReferenceType;
    alias xsType = char;
    alias xsBooleanValue = int;
    alias xsIntegerValue = int;
    alias xsNumberValue = double;
    alias xsStringValue = char*;
    alias xsUnsignedValue = uint;
    void fxStringX(xsMachineRecord*, xsSlotRecord*, char*) @nogc nothrow;
    void fxStringBuffer(xsMachineRecord*, xsSlotRecord*, char*, int) @nogc nothrow;
    void fxString(xsMachineRecord*, xsSlotRecord*, char*) @nogc nothrow;
    double fxToNumber(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxNumber(xsMachineRecord*, xsSlotRecord*, double) @nogc nothrow;
    int fxToInteger(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxInteger(xsMachineRecord*, xsSlotRecord*, int) @nogc nothrow;
    int fxToBoolean(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxBoolean(xsMachineRecord*, xsSlotRecord*, int) @nogc nothrow;
    void fxNull(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    void fxUndefined(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    char fxTypeOf(xsMachineRecord*, xsSlotRecord*) @nogc nothrow;
    enum _Anonymous_1
    {
        xsDebuggerExit = 0,
        xsNotEnoughMemoryExit = 1,
        xsStackOverflowExit = 2,
        xsFatalCheckExit = 3,
        xsDeadStripExit = 4,
        xsUnhandledExceptionExit = 5,
        xsNoMoreKeysExit = 6,
        xsTooMuchComputationExit = 7,
    }
    enum xsDebuggerExit = _Anonymous_1.xsDebuggerExit;
    enum xsNotEnoughMemoryExit = _Anonymous_1.xsNotEnoughMemoryExit;
    enum xsStackOverflowExit = _Anonymous_1.xsStackOverflowExit;
    enum xsFatalCheckExit = _Anonymous_1.xsFatalCheckExit;
    enum xsDeadStripExit = _Anonymous_1.xsDeadStripExit;
    enum xsUnhandledExceptionExit = _Anonymous_1.xsUnhandledExceptionExit;
    enum xsNoMoreKeysExit = _Anonymous_1.xsNoMoreKeysExit;
    enum xsTooMuchComputationExit = _Anonymous_1.xsTooMuchComputationExit;
    enum _Anonymous_2
    {
        XS_IMPORT_NAMESPACE = 0,
        XS_IMPORT_DEFAULT = 1,
        XS_IMPORT_PREFLIGHT = 2,
    }
    enum XS_IMPORT_NAMESPACE = _Anonymous_2.XS_IMPORT_NAMESPACE;
    enum XS_IMPORT_DEFAULT = _Anonymous_2.XS_IMPORT_DEFAULT;
    enum XS_IMPORT_PREFLIGHT = _Anonymous_2.XS_IMPORT_PREFLIGHT;
    alias xsAttribute = ubyte;
    enum _Anonymous_3
    {
        xsNoID = -1,
        xsDefault = 0,
        xsDontDelete = 2,
        xsDontEnum = 4,
        xsDontSet = 8,
        xsStatic = 16,
        xsIsGetter = 32,
        xsIsSetter = 64,
        xsChangeAll = 30,
    }
    enum xsNoID = _Anonymous_3.xsNoID;
    enum xsDefault = _Anonymous_3.xsDefault;
    enum xsDontDelete = _Anonymous_3.xsDontDelete;
    enum xsDontEnum = _Anonymous_3.xsDontEnum;
    enum xsDontSet = _Anonymous_3.xsDontSet;
    enum xsStatic = _Anonymous_3.xsStatic;
    enum xsIsGetter = _Anonymous_3.xsIsGetter;
    enum xsIsSetter = _Anonymous_3.xsIsSetter;
    enum xsChangeAll = _Anonymous_3.xsChangeAll;
    alias xsCallbackAt = void function(xsMachineRecord*) function(short);
    enum _Anonymous_4
    {
        XS_NO_ERROR = 0,
        XS_UNKNOWN_ERROR = 1,
        XS_EVAL_ERROR = 2,
        XS_RANGE_ERROR = 3,
        XS_REFERENCE_ERROR = 4,
        XS_SYNTAX_ERROR = 5,
        XS_TYPE_ERROR = 6,
        XS_URI_ERROR = 7,
        XS_ERROR_COUNT = 8,
    }
    enum XS_NO_ERROR = _Anonymous_4.XS_NO_ERROR;
    enum XS_UNKNOWN_ERROR = _Anonymous_4.XS_UNKNOWN_ERROR;
    enum XS_EVAL_ERROR = _Anonymous_4.XS_EVAL_ERROR;
    enum XS_RANGE_ERROR = _Anonymous_4.XS_RANGE_ERROR;
    enum XS_REFERENCE_ERROR = _Anonymous_4.XS_REFERENCE_ERROR;
    enum XS_SYNTAX_ERROR = _Anonymous_4.XS_SYNTAX_ERROR;
    enum XS_TYPE_ERROR = _Anonymous_4.XS_TYPE_ERROR;
    enum XS_URI_ERROR = _Anonymous_4.XS_URI_ERROR;
    enum XS_ERROR_COUNT = _Anonymous_4.XS_ERROR_COUNT;
    alias xsSweeper = void function(xsMachineRecord*, void*, void function(xsMachineRecord*, xsSlotRecord*));
    alias xsSweepRoot = void function(xsMachineRecord*, xsSlotRecord*);
    alias xsMarker = void function(xsMachineRecord*, void*, void function(xsMachineRecord*, xsSlotRecord*));
    alias xsMarkRoot = void function(xsMachineRecord*, xsSlotRecord*);
    alias xsDestructor = void function(void*);
    alias xsCallback = void function(xsMachineRecord*);
    alias xsIndex = short;
    alias xsFlag = ubyte;
}


