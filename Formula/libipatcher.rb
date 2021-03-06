class Libipatcher < Formula
  desc "Convinient wrapper for iBoot32Patcher"
  homepage "https://github.com/tihmstar/libipatcher"
  url "https://github.com/tihmstar/libipatcher.git",
    :revision => "80df8700f52e6eb8777a28bfcc19f86da7d9b9b9"
  version "68"

  head "https://github.com/tihmstar/libipatcher.git"
  keg_only "I don't want this in /usr/local"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build # xpwn
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  depends_on "img4tool"
  depends_on "libgeneral"
  depends_on "liboffsetfinder64"
  depends_on "libpng"
  depends_on "libusb"
  depends_on "openssl"

  resource "xpwn" do
    url "https://github.com/tihmstar/xpwn.git"
  end

  def build_libxpwn
    xpwndir = "#{buildpath}/external/xpwn"
    mkdir_p xpwndir

    resource("xpwn").stage do
      inreplace "ipsw-patch/CMakeLists.txt", "powerpc-apple-darwin8-libtool", "libtool"

      mkdir "builddir" do
        system "cmake", "..", *std_cmake_args
        system "make", "libXPwn.a", "common"
        cp "ipsw-patch/libxpwn.a", xpwndir
        cp "common/libcommon.a", xpwndir
      end

      cp_r "includes", xpwndir
    end
  end

  patch :p0, :DATA

  def fix_tihmstar
    touch "LICENSE"
    touch "COPYING"

    files = %w[libipatcher.pc.in]
    inreplace files.select { |f| File.exist? f },
#     "git rev-list --count HEAD",
#     "echo #{version.to_s.gsub(/[^\d]/, "")}",
#     false
      "@VERSION_COMMIT_COUNT@",
      "68"                      # I don't know enough Ruby nor regex to be able to make this work.
  end

  def install
    fix_tihmstar

    build_libxpwn

    system "./autogen.sh", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

__END__
diff --git libipatcher/Makefile.am libipatcher/Makefile.am
--- libipatcher/Makefile.am
+++ libipatcher/Makefile.am
@@ -1,6 +1,9 @@
 AM_CFLAGS = -I$(top_srcdir)/include -I$(top_srcdir)/external/iBoot32Patcher -I$(top_srcdir)/external/jssy/jssy/ $(libpng_CFLAGS)
 AM_LDFLAGS = -L$(top_srcdir)/libipatcher -L/usr/local/lib/ -lcommon -lxpwn $(libpng_LIBS) $(openssl_LIBS)

+AM_CFLAGS += -I$(includedir) -I$(top_srcdir)/external/xpwn/includes
+AM_LDFLAGS += -L$(libdir) -L$(top_srcdir)/external/xpwn
+
 noinst_LTLIBRARIES = libiBoot32Patcher.la libjssy.la
 lib_LTLIBRARIES = libipatcher.la

