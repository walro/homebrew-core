class Afflib < Formula
  desc "Advanced Forensic Format"
  homepage "https://github.com/sshock/AFFLIBv3"
  url "https://github.com/sshock/AFFLIBv3/archive/v3.7.10.tar.gz"
  sha256 "906226df05d526b886a873367ca896f0058a6221c2e21c900411d0fc89754c2b"

  bottle do
    cellar :any
    sha256 "aed0e63b8aa3504075b9a2bbeafb06a0f8813332c32bf0c421604ebf5ea40856" => :el_capitan
    sha256 "9ed21fce9069ccd07e5e87674fcba8c77ef48c24cf1628c1d05a74daf5a417c7" => :yosemite
    sha256 "a81617f0907d054b745d0a0f886ae14fa472193f9722258fa1933854907cc519" => :mavericks
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "expat" => :optional
  depends_on osxfuse: :optional
  depends_on "openssl"

  # This patch fixes a bug reported upstream over there
  # https://github.com/simsong/AFFLIBv3/issues/4
  patch :DATA

  def install
    system "./bootstrap.sh"

    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]

    if build.with? "osxfuse"
      ENV["CPPFLAGS"] = "-I#{Formula["osxfuse"].include}/osxfuse"
      args << "--enable-fuse"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/affcat", "-v"
  end
end

__END__
diff --git a/bootstrap.sh b/bootstrap.sh
index 3a7af59..7510933 100755
--- a/bootstrap.sh
+++ b/bootstrap.sh
@@ -6,7 +6,7 @@
 echo Bootstrap script to create configure script using autoconf
 echo
 # use the installed ones first, not matter what the path says.
-export PATH=/usr/bin:/usr/sbin:/bin:$PATH
+#export PATH=/usr/bin:/usr/sbin:/bin:$PATH
 touch NEWS README AUTHORS ChangeLog stamp-h
 aclocal
 LIBTOOLIZE=glibtoolize
diff --git a/configure.ac b/configure.ac
index 940353b..c530f2e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -241,10 +241,6 @@ AC_ARG_ENABLE(fuse,
 if test "x${enable_fuse}" = "xyes" ; then
   AC_MSG_NOTICE([FUSE requested])
   CPPFLAGS="-D_FILE_OFFSET_BITS=64 -DFUSE_USE_VERSION=26 $CPPFLAGS"
-  if test `uname -s` = Darwin ; then
-    AC_MSG_NOTICE([FUSE IS NOT SUPPORTED ON MACOS])
-    enable_fuse=no
-  fi
   AC_CHECK_HEADER([fuse.h],,
     AC_MSG_NOTICE([fuse.h not found; Disabling FUSE support.])
     enable_fuse=no)
@@ -255,7 +251,7 @@ AFFUSE_BIN=
 if test "${enable_fuse}" = "yes"; then
   AC_DEFINE([USE_FUSE],1,[Use FUSE to mount AFF images])
   AFFUSE_BIN='affuse$(EXEEXT)'
-  FUSE_LIBS=-lfuse
+  FUSE_LIBS=-losxfuse
 fi
 AC_SUBST(AFFUSE_BIN)
 AM_PROG_CC_C_O			dnl for affuse
