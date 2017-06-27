                 Java(tm) Secure Socket Extension 1.0.3_02

                               README


----------------------------------------------------------------------
CONTENTS
----------------------------------------------------------------------

     * Introduction
     * Understanding The Export/Import Issues
     * Where To Find Documentation
     * Questions, Support, Reporting Bugs, and Feedback
     * Miscellaneous Credits


----------------------------------------------------------------------
Introduction
----------------------------------------------------------------------

Thank you for downloading the Java(tm) Secure Socket Extension (JSSE)
1.0.3_02.  JSSE 1.0.3_02 supplements the Java 2 platform v 1.2.x or 
1.3.x, and requires that you have it installed.  This implementation
is not for use in the Java 2 platform v 1.4 or greater, as
the 1.4 platform already includes JSSE.

JSSE 1.0.3_02 is written entirely in the Java(tm) programming language.


----------------------------------------------------------------------
Understanding The Export/Import Issues
----------------------------------------------------------------------

JSSE 1.0.3_02 has ENC/Retail status.  A product which bundles 
JSSE 1.0.3_02 may be globally distributable and/or importable. You 
are advised to consult your export/import control counsel or attorney 
to determine the exact requirements.

Recent changes in the United States export regulations allow Sun to
include strong cryptographic algorithms in the global version of JSSE
1.0.3_02. Note that while there are two downloads, a domestic (US/Canada)
and a global version, they provide the same encryption strength.  The
domestic version supports alternate SSL security providers; the global
version supports only the Sun SSL provider.

For more information on U.S. encryption policies, refer to these web
sites:

	U.S. Dept of Commerce		www.doc.gov
	Export Policy Resource Page	www.crypto.com
	Computer Systems Public Policy  www.cspp.org

Reference sites for more information:

	Bruce Schneier's site		www.counterpane.com
	Gene Spafford's site		www.cs.purdue.edu/coast/coast.html


----------------------------------------------------------------------
Where To Find Documentation
----------------------------------------------------------------------

Once you have installed JSSE 1.0.3, you will be able to read more
detailed information about the software and how to use it.

The following documents will be of interest to you:

    *	An "API Specification & Reference" document:

		<java-home>/doc/guide/API_users_guide.html

    *	JSSE 1.0.3 javadocs:

		<java-home>/doc/apidoc/index.html

	(<java-home> is the name of the directory that is automatically
	created when you extract JSSE 1.0.3.)

    *	The Java Security Web site has more information about the JSSE,
	plus additional information about the Java 2 Security Model.
	Please see:

		http://java.sun.com/products/jsse/
		http://java.sun.com/security/


-----------------------------------------------------------------------
Questions, Support, Reporting Bugs, and Feedback
-----------------------------------------------------------------------

Questions
---------

For miscellaneous questions about JSSE 1.0.3 usage and deployment, 
we encourage you to read:

    *	the JSSE 1.0.3 Frequently Asked Questions, available from the
	JSSE web site

		http://java.sun.com/products/jsse

    *	the Java Security Q&A Archives 

		http://archives.java.sun.com/archives/java-security.html

    *	the Java Developer Connection forums. These discussion forums 
	allow you to tap into the experience of other users, ask 
	questions, or offer tips to others on a variety of Java-related
	topics including JSSE 1.0.3. There is no fee to participate.

		http://forums.java.sun.com/
 
Although not supported by Sun, an alternative for technical 
expertise may be found at:

	http://www.hotdispatch.com/sun


Support
-------

For more extensive JSSE 1.0.3_02 questions or deployment issues, Sun 
currently offers several levels of developer support for the Java 2 
platform (including the JSSE 1.0.3_02 optional package): 

    *	Per-Incident 
    *	Developer Access Direct(SM) 
    *	Developer Access Plus(SM)

For more information, please see 

	http://www.sun.com/developer/support/

Please be aware that we may be barred from offering technical support
specifically regarding encryption implementations of the JSSE APIs to
people outside the U.S. or Canada, according to U.S. regulations.


Reporting Bugs
--------------

Please submit bugs with sample code using the normal Java Developer 
Connection (JDC) process at:

	http://java.sun.com/cgi-bin/bugreport.cgi

Bug reports with sample code are highly appreciated!  


Feedback
--------

Please e-mail general comments about JSSE 1.0.3 to:

	java-security@sun.com

The above mailing list is not a subscription list.  It is simply a
one-way channel that you can use to send comments to the Java 2
Standard Edition security group.

Though we value your input, before sending your feedback please review
our pages of Frequently Asked Questions, available from the JSSE web
site:

	http://java.sun.com/products/jsse

and search the Java Security Q&A Archives:

	http://archives.java.sun.com/archives/java-security.html

Please note that due to the volume of messages we receive, we 
may not be able to respond to every individual message. 

For other comments/suggestions concerning the web sites please 
use the feedback form at:

        http://java.sun.com/feedback/index.html


----------------------------------------------------------------------
Miscellaneous Credits
----------------------------------------------------------------------

Portions of this release of JSSE 1.0.3_02 include binary bytecode which is
subject to the following notice:

// Copyright (C) 1996 by Jef Poskanzer <jef@acme.com>.  All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
// Visit the ACME Labs Java page for up-to-date versions of this and other
// fine Java utilities: http://www.acme.com/java/
