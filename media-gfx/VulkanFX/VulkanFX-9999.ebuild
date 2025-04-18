# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit meson-multilib

DESCRIPTION="A vulkan post processing layer"
HOMEPAGE="https://github.com/pchome/VulkanFX"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/pchome/VulkanFX.git"
	EGIT_SUBMODULES=()
	inherit git-r3
	SRC_URI=""
else
	SRC_URI="https://github.com/pchome/VulkanFX/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
	S="${WORKDIR}/VulkanFX-${PV}"
fi

LICENSE="ZLIB"
SLOT="0"

IUSE="+xlib"
REQUIRED_USE="xlib" # there is no option yet to disable this

RESTRICT="test"

RDEPEND="!<media-libs/vulkan-loader-1.1:=[${MULTILIB_USEDEP},layers]
	!media-gfx/vkBasalt
	>=dev-util/reshade-fx-6.4.1[${MULTILIB_USEDEP},spirv]"

BDEPEND="!<dev-util/vulkan-headers-1.1
	dev-util/glslang
	dev-libs/stb
	media-libs/vkroots
	>=dev-build/meson-0.50"

DEPEND="${RDEPEND}
	xlib? ( x11-libs/libX11[${MULTILIB_USEDEP}] )"

multilib_src_configure() {
	local emesonargs=(
		--unity=on
		-Dunity_size=100
	)
	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}
