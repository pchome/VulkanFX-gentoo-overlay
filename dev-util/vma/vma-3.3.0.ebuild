# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Easy to integrate Vulkan memory allocation library"
HOMEPAGE="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator"
SRC_URI="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/VulkanMemoryAllocator-${PV}"

LICENSE="MIT"
SLOT="0"
IUSE="doc samples"
KEYWORDS="~amd64"
RESTRICT="test"

BDEPEND="
	doc? ( app-text/doxygen )
"
RDEPEND="
	samples? ( dev-util/volk )
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DVMA_ENABLE_INSTALL=ON
		-DVMA_BUILD_DOCUMENTATION=$(usex doc)
		-DVMA_BUILD_SAMPLES=$(usex samples)
	)

	cmake_src_configure
}
