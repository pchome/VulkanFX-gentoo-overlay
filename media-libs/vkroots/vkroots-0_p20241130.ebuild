# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Regenerating vkroots.h from the system vk.xml may seem like a good idea,
# especially given that vkroots.h includes some Vulkan headers, but this has led
# to issues such as https://github.com/ValveSoftware/gamescope/issues/858.
# Leaving the code commented in case we need to revert to the earlier approach.

# PYTHON_COMPAT=( python3_{10..11} )

# inherit meson python-any-r1

inherit meson

COMMIT="a1ce1dad9a0beff57eaf925116a0e49b5e5e0be3"
DESCRIPTION="Simple framework for writing Vulkan layers"
HOMEPAGE="https://github.com/Joshua-Ashton/vkroots"
SRC_URI="https://github.com/Joshua-Ashton/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"
LICENSE="Apache-2.0 MIT LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"

# BDEPEND="
# 	${PYTHON_DEPS}
# 	dev-util/vulkan-headers
# "

RDEPEND="
	dev-util/vulkan-headers
"

# This package is a header file, should behave the same as e.g. spirv-headers
# pkgconfig file goes to /usr/share/pkgconfig
PATCHES=(
	"${FILESDIR}"/pkgconfig.patch
)

# src_compile() {
# 	"${PYTHON}" ./gen/make_vkroots --xml "${BROOT}"/usr/share/vulkan/registry/vk.xml || die
# }
