# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fcaps meson

MY_PV=$(ver_rs 3 -)
MY_PV="${MY_PV//_/-}"

DESCRIPTION="SDL3 micro-compositor for running games"
HOMEPAGE="https://github.com/pchome/gamescope-lite"
EGIT_SUBMODULES=( subprojects/wlroots )

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/pchome/${PN}.git"
	inherit git-r3
else
	WLROOTS_COMMIT="e99c2e5c427f5543cf6ddcbc22f7eecd658edaed"
	SRC_URI="
		https://github.com/pchome/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz
		https://github.com/pchome/wlroots/archive/${WLROOTS_COMMIT}.tar.gz -> wlroots-${WLROOTS_COMMIT}.tar.gz
	"
	KEYWORDS="~amd64"
fi

S="${WORKDIR}/${PN}-${MY_PV}"
LICENSE="BSD-2"
SLOT="0"
IUSE="avif gui headless pipewire reshade screenshot"

RDEPEND="
	>=dev-libs/wayland-1.23.1
	filecaps? ( sys-libs/libcap )
	>=x11-libs/libdrm-2.4.109
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	>=x11-libs/libxkbcommon-1.8.0
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXres
	x11-libs/libXxf86vm
	>=x11-libs/pixman-0.43.0
	avif? ( >=media-libs/libavif-1.0.0:= )
	pipewire? ( >=media-video/pipewire-0.3:= )
	media-libs/libsdl3[vulkan]
"
# For bundled wlroots.
RDEPEND+="
	media-libs/libglvnd
	>=media-libs/mesa-24.1.0_rc1[opengl]
	x11-base/xwayland
	x11-libs/libxcb:=
	x11-libs/xcb-util-wm
"
DEPEND="
	${RDEPEND}
	>=dev-libs/wayland-protocols-1.41
	>=dev-libs/stb-20240201-r1
	dev-util/vulkan-headers
	>=media-libs/glm-1.0.1
	reshade? (
	    dev-util/spirv-headers
	    >=dev-util/reshade-fx-6.6.2
	)
"
BDEPEND="
	dev-util/glslang
	dev-util/wayland-scanner
	virtual/pkgconfig
"

FILECAPS=(
	cap_sys_nice usr/bin/${PN}
)

src_prepare() {
	# Upstream have requested that we do not unbundle wlroots.
	# Symlink to the extracted sources when not using the git submodules in 9999.
	if [[ ${PV} != "9999" ]]; then
		local dir name commit
		for dir in "${EGIT_SUBMODULES[@]}"; do
			rmdir "${dir}" || die
			name=${dir##*/}
			commit=${name^^}_COMMIT
			#ln -snfT "../../${name}-${!commit}" "${dir}" || die
			mv "../${name}-${!commit}" "${dir}" || die
		done
		# Display correct version
		sed "s#vcs_tag = .*#vcs_tag = '${PV}'#" -i src/meson.build || die
	fi

	default
}

src_configure() {
	local emesonargs=(
		$(meson_feature gui ui)
		$(meson_feature pipewire)
		$(meson_feature filecaps rt_cap)
		$(meson_feature avif avif_screenshots)
		$(meson_feature screenshot)
		$(meson_feature headless)
		$(meson_feature reshade)

		-Dwlroots:xcb-errors=disabled
		-Dwlroots:examples=false
		-Dwlroots:renderers=[]
		-Dwlroots:xwayland=enabled
		-Dwlroots:backends=[]
		-Dwlroots:session=disabled
		-Dwlroots:allocators=[]
		-Dwlroots:libliftoff=disabled
		-Dwlroots:color-management=disabled
	)
	meson_src_configure
}

src_install() {
	meson_src_install --skip-subprojects
}
