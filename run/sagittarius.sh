#!/bin/sh
. run/_ostype.sh
exec sagittarius --loadpath=$YUNIMOD --loadpath=lib-runtime/r7rs --loadpath=lib-stub/r6rs-common --loadpath=lib-stub/sagittarius --loadpath=lib-stub/gen --loadpath=lib-compat $*
