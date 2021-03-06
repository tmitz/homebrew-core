class Gspell < Formula
  desc "Flexible API to implement spellchecking in GTK+ applications"
  homepage "https://wiki.gnome.org/Projects/gspell"
  url "https://download.gnome.org/sources/gspell/1.2/gspell-1.2.3.tar.xz"
  sha256 "a64e158e47a6e2b8ec9a3a1fea98a416f78a13e275c909b2ed488494ff835f82"

  bottle do
    sha256 "7c60f9943861c4319d9a6138efc578e70713a25140cff87550bddbf6b5c7615b" => :sierra
    sha256 "280a6ddcd63dff23dfd270b85f5c89d1d985f60e58de945b3359c9ff27c882e7" => :el_capitan
    sha256 "fc5763ba5af6c0f7f6310759f73c18a978c9469f456c616a011e502406d235a1" => :yosemite
  end

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "enchant"
  depends_on "gtk+3"
  depends_on "gtk-mac-integration"
  depends_on "iso-codes"
  depends_on "vala" => :recommended

  # ensures compilation on macOS
  # submitted upstream as https://bugzilla.gnome.org/show_bug.cgi?id=759704
  patch :DATA

  def install
    system "autoreconf", "-i"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gspell/gspell.h>

      int main(int argc, char *argv[]) {
        const GList *list = gspell_language_get_available();
        return 0;
      }
    EOS
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    enchant = Formula["enchant"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gtkx3 = Formula["gtk+3"]
    gtk_mac_integration = Formula["gtk-mac-integration"]
    harfbuzz = Formula["harfbuzz"]
    libepoxy = Formula["libepoxy"]
    libpng = Formula["libpng"]
    pango = Formula["pango"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{enchant.opt_include}/enchant
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gtk_mac_integration.opt_include}/gtkmacintegration
      -I#{gtkx3.opt_include}/gtk-3.0
      -I#{harfbuzz.opt_include}/harfbuzz
      -I#{include}/gspell-1
      -I#{libepoxy.opt_include}
      -I#{libpng.opt_include}/libpng16
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -DMAC_INTEGRATION
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gtkx3.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lgdk-3
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lgspell-1
      -lgtk-3
      -lintl
      -lpango-1.0
      -lpangocairo-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end

__END__
diff --git a/gspell/Makefile.am b/gspell/Makefile.am
index f025b4d..13c9743 100644
--- a/gspell/Makefile.am
+++ b/gspell/Makefile.am
@@ -11,7 +11,8 @@ AM_CPPFLAGS =				\
	$(WARN_CFLAGS)			\
	$(CODE_COVERAGE_CPPFLAGS)	\
	$(DEP_CFLAGS)			\
-	$(GTK_MAC_CFLAGS)
+	$(GTK_MAC_CFLAGS)               \
+	-xobjective-c

 BUILT_SOURCES =			\
	gspell-resources.c
@@ -75,7 +76,13 @@ libgspell_core_la_CFLAGS = \
 libgspell_core_la_LDFLAGS =		\
	-no-undefined			\
	$(WARN_LDFLAGS)			\
-	$(CODE_COVERAGE_LDFLAGS)
+	$(CODE_COVERAGE_LDFLAGS)        \
+	-framework Cocoa -framework Foundation -framework Cocoa
+
+
+libgspell_core_la_LIBADD =		\
+	$(GTK_MAC_LIBS)
+

 # The real library.
 lib_LTLIBRARIES = libgspell-@GSPELL_API_VERSION@.la
@@ -95,7 +102,8 @@ libgspell_@GSPELL_API_VERSION@_la_LDFLAGS =	\
	-no-undefined				\
	-export-symbols-regex "^gspell_.*"	\
	$(WARN_LDFLAGS)				\
-	$(CODE_COVERAGE_LDFLAGS)
+	$(CODE_COVERAGE_LDFLAGS)                \
+	-framework Cocoa -framework Foundation -framework Cocoa

 libgspell_includedir = $(includedir)/gspell-@GSPELL_API_VERSION@/gspell
 libgspell_include_HEADERS = $(gspell_public_headers)
@@ -108,7 +116,7 @@ CLEANFILES = $(BUILT_SOURCES)

 if OS_OSX
 libgspell_@GSPELL_API_VERSION@_la_LDFLAGS += \
-	-framework Cocoa
+	-framework Cocoa -framework Foundation -framework Cocoa

 libgspell_@GSPELL_API_VERSION@_la_CFLAGS += \
	-xobjective-c
