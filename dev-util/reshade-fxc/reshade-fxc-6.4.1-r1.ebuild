# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="The ReShade FX shader compiler"
HOMEPAGE="https://github.com/crosire/reshade"
SRC_URI="https://github.com/crosire/reshade/archive/v${PV}.tar.gz -> reshade-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="test"

DEPEND="dev-util/reshade-fx:=[glsl,hlsl,spirv]"
RDEPEND=""
BDEPEND="${DEPEND}"

S="${WORKDIR}/reshade-${PV}"

# TMP Hack for vkBasalt config helper
PATCHES=(
	"${FILESDIR}/reshade-fxc.cpp-${PV}.patch"
	"${FILESDIR}/reshade-fx2conf.cpp-${PV}.patch"
)

src_configure() {
	# Create meson.build file
	# meson init -n reshade-fxc -d ReShadeFX --type executable --version 4.8.2 tools/fxc.cpp
	cat > "${S}/meson.build" <<-EOF
	project('${PN}', ['cpp'], default_options : ['cpp_std=c++20'], version : '${PV}', meson_version : '>= 0.46')
	
	reshadefx_dep = [
	  dependency('ReShadeFX'),
	  dependency('ReShadeFX-spirv'),
	  dependency('ReShadeFX-glsl'),
	  dependency('ReShadeFX-hlsl'),
	]
	
	# Binary
	executable('reshade-fxc', 'tools/fxc.cpp', dependencies: reshadefx_dep, install: true)
	
	# https://github.com/DadSchoorse/ReshadeFxCompiler/pull/1
	executable('reshade-fx2conf', 'tools/fx2conf.cpp', dependencies: reshadefx_dep, install: true)
	EOF

	# Create version file
	cat > "${S}/tools/version.h" <<-EOF
	#define VERSION_MAJOR $(ver_cut 1)
	#define VERSION_MINOR $(ver_cut 2)
	#define VERSION_REVISION $(ver_cut 3)
	#define VERSION_STRING_PRODUCT "ReShade FX compiler"
	EOF

	meson_src_configure
}

src_install() {
	meson_src_install
}
