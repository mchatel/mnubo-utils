#!/bin/sh

TMPFILE1=/tmp/mnu-license.base.$$

cat << LICENSE_EOF1 > $TMPFILE1
# START_MNU_FREE_LICENSE
#
# This file is part of mnuboot-bnr , the backup & restore on boot utility,
# currently available on the Internet at https://github.com/mnubo/utils
#
# Copyright (C) 2014-2015 Mnubo
# Written by Marc Chatel <mchatel@mnubo.com>, <chatelm@yahoo.com>, 2014.
#
# mnuboot-bnr is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.  */
#
# END_MNU_FREE_LICENSE
LICENSE_EOF1

FILE_LIST=`find . -type f -print | sort`

for F in $FILE_LIST
do
   NUM_START=`cat $F | grep "START_MNU_FREE_LICENSE" | wc -l`
   NUM_END=`cat   $F | grep "END_MNU_FREE_LICENSE"   | wc -l`

   if [ $NUM_START -ne 1 -o $NUM_END -ne 1 -o "$F" = "./sync-license.sh" ]
   then
      echo "Skipping $F ..."
   else
      echo "Processing $F ..."

      F_NUM_LINES=`cat $F | wc -l`

      F_START_LINE_NO=`cat $F | grep -n "START_MNU_FREE_LICENSE" | \
                                sed -e 's/:.*//'`
      F_END_LINE_NO=`cat   $F | grep -n "END_MNU_FREE_LICENSE"   | \
                                sed -e 's/:.*//'`

      F_START_NUM_LINES=`expr $F_START_LINE_NO - 1`
      F_END_NUM_LINES=`expr $F_NUM_LINES - $F_END_LINE_NO`

      cat $F | head --lines=$F_START_NUM_LINES >  $F.new
      cat $TMPFILE1                            >> $F.new
      cat $F | tail --lines=$F_END_NUM_LINES   >> $F.new

      DIFF_RESULT=`diff -q $F $F.new`

      if [ "X$DIFF_RESULT" != "X" ]
      then
         echo "   Overwriting $F with updated copy ..."
         cat < $F.new > $F
      fi

      rm -f $F.new
   fi
done

rm -f $TMPFILE1
