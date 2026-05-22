# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib

DESCRIPTION="A custom shader language called ReShade FX"
HOMEPAGE="https://github.com/crosire/reshade"
SRC_URI="https://github.com/pchome/reshade-fx/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
IUSE="fxc +glsl +hlsl +spirv"
REQUIRED_USE="|| ( glsl hlsl spirv )"
KEYWORDS="~amd64 ~x86"
RESTRICT="test"

DEPEND=">=dev-util/spirv-headers-1.4"
RDEPEND=""
BDEPEND="${DEPEND}"
#	spirv? ( dev-util/vma )"

#S="${WORKDIR}/reshade-${PV}"

multilib_src_configure() {
	local emesonargs=(
		$(meson_feature spirv)
		$(meson_feature hlsl)
		$(meson_feature glsl)
		$(meson_use fxc build_fxc)
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	dodoc README.md REFERENCE.md
}
