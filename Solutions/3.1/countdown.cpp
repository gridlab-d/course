/* automatically generated from GridLAB-D */

int major=0, minor=0;

#include "rt/gridlabd.h"

int __declspec(dllexport) dllinit() { return 0;};
int __declspec(dllexport) dllkill() { return 0;};
CALLBACKS *callback = NULL;
static CLASS *myclass = NULL;
static void setup_class(CLASS *);

extern "C" CLASS *init(CALLBACKS *fntable, MODULE *module, int argc, char *argv[])
{
	callback=fntable;
	myclass=(CLASS*)((*(callback->class_getname))("countdown"));
	setup_class(myclass);
	return myclass;}
#line 4 "countdown.glm"
class countdown {
public:
	countdown(MODULE*mod) {};
#line 4 "countdown.glm"
#line 5 "countdown.glm"
	int32 a;
#line 27 "countdown.cpp"
#line 6 "countdown.glm"
	int64 create (object parent) { OBJECT*my=((OBJECT*)this)-1;
	try {
		a = 10;
		return SUCCESS;
	} catch (char *msg) {callback->output_error("%s[%s:%d] exception - %s",my->name?my->name:"(unnamed)",my->oclass->name,my->id,msg); return 0;} catch (...) {callback->output_error("%s[%s:%d] unhandled exception",my->name?my->name:"(unnamed)",my->oclass->name,my->id); return 0;} callback->output_error("countdown::create(object parent) not all paths return a value"); return 0;}
#line 34 "countdown.cpp"
#line 10 "countdown.glm"
	int64 init (object parent) { OBJECT*my=((OBJECT*)this)-1;
	try {
		if (a<0) gl_throw("a=%d is not valid",a);
		return SUCCESS;
	} catch (char *msg) {callback->output_error("%s[%s:%d] exception - %s",my->name?my->name:"(unnamed)",my->oclass->name,my->id,msg); return 0;} catch (...) {callback->output_error("%s[%s:%d] unhandled exception",my->name?my->name:"(unnamed)",my->oclass->name,my->id); return 0;} callback->output_error("countdown::init(object parent) not all paths return a value"); return 0;}
#line 41 "countdown.cpp"
#line 14 "countdown.glm"
	TIMESTAMP sync (timestamp t0, timestamp t1) { OBJECT*my=((OBJECT*)this)-1;
	try {
		gl_output("%d",a--);
		return a>=0 ? t1 + 1 : TS_NEVER;
	} catch (char *msg) {callback->output_error("%s[%s:%d] exception - %s",my->name?my->name:"(unnamed)",my->oclass->name,my->id,msg); return 0;} catch (...) {callback->output_error("%s[%s:%d] unhandled exception",my->name?my->name:"(unnamed)",my->oclass->name,my->id); return 0;} callback->output_error("countdown::sync(timestamp t0, timestamp t1) not all paths return a value"); return 0;}
#line 48 "countdown.cpp"
};
#line 50 "countdown.cpp"
#line 51 "countdown.cpp"
extern "C" int64 create_countdown(OBJECT **obj, OBJECT *parent)
{
	if ((*obj=gl_create_object(myclass))==NULL)
		return 0;
	memset((*obj)+1,0,sizeof(countdown));
	gl_set_parent(*obj,parent);
	int64 ret = ((countdown*)((*obj)+1))->create(parent);
	return ret;
}
#line 61 "countdown.cpp"
extern "C" int64 init_countdown(OBJECT *obj, OBJECT *parent)
{
	int64 ret = ((countdown*)(obj+1))->init(parent);
	return ret;
}
#line 67 "countdown.cpp"
extern "C" int64 sync_countdown(OBJECT *obj, TIMESTAMP t1, PASSCONFIG pass)
{
	int64 t2 = TS_NEVER;
	switch (pass) {
	case PC_BOTTOMUP:
		t2=((countdown*)(obj+1))->sync(obj->clock,t1);
		obj->clock = t2;
		break;
	default:
		break;
	}
	return t2;
}
static void setup_class(CLASS *oclass)
{	
	OBJECT obj; obj.oclass = oclass; countdown *t = (countdown*)(&obj)+1;
	oclass->size = sizeof(countdown);
	(*(callback->properties.get_property))(&obj,"a")->addr = (PROPERTYADDR)((char*)&(t->a) - (char*)t);

}
