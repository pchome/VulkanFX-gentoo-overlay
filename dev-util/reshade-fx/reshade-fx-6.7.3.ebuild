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
REQUIRED_USE="|| ( glsl hlsl spirv ) fxc? ( glsl hlsl spirv )"
KEYWORDS="~amd64 ~x86"
RESTRICT="test"

DEPEND=">=dev-util/spirv-headers-1.4"
RDEPEND="fxc? ( !dev-util/reshade-fxc )"
BDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/reshade-fx-6.7.3-build-silence-warnings.patch"
	"${FILESDIR}/reshade-fx-6.7.3-build-fix-Wrange-loop-construct-warning.patch"
	"${FILESDIR}/reshade-fx-6.7.3-revert_finalize_code_cleanup.patch"
)

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
