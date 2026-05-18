const fs = require('fs')
const path = require('path')
const { execFileSync } = require('child_process')
const { MachO, ELF } = require('bare-lief')

const libraries = process.argv.slice(2)

for (const library of libraries) {
  if (/\.dylib(\.([0-9]+(\.[0-9]+)*))?$/.test(library)) {
    const fat = MachO.FatBinary.parse(fs.readFileSync(library))

    for (const binary of fat) {
      for (const dependency of binary.libraries) {
        const name = dependency.name

        if (name.startsWith('/usr') || name.startsWith('/System')) continue

        dependency.name = '@rpath/' + path.basename(name)
      }
    }

    fat.toDisk(library)

    execFileSync('codesign', ['--sign', '-', '--force', library], { stdio: 'ignore' })
  } else if (/\.so(\.([0-9]+(\.[0-9]+)*))?$/.test(library)) {
    const elf = ELF.Binary.parse(fs.readFileSync(library))

    const soname = elf.getDynamicEntry(ELF.DynamicEntry.TAG.SONAME)

    if (soname) {
      soname.name = path.basename(library)
    } else {
      elf.addDynamicEntry(new ELF.DynamicEntry.SharedObject(path.basename(library)))
    }

    elf.toDisk(library)
  }
}
