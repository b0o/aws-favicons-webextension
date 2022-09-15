import path from "path"
import fs from "fs/promises"
import esbuild from "esbuild"
import { fileURLToPath } from "url"

const hasArg = (a) => process.argv.includes(a)

const args = {
  verbose: hasArg("--verbose"),
  minify: hasArg("--minify"),
  manifestV3: hasArg("--v3"),
}

const log = (...args) => {
  if (args.verbose) {
    console.log(...args)
  }
}

const paths = {}
paths.buildScriptPath = fileURLToPath(import.meta.url)
paths.scriptsDir = path.dirname(paths.buildScriptPath)
paths.rootDir = path.dirname(paths.scriptsDir)

const repoPath = (...p) => path.join(paths.rootDir, ...p)

paths.buildDir = repoPath(`build/v${args.manifestV3 ? 3 : 2}`)
paths.srcDir = repoPath("src")
paths.assetsDir = repoPath("assets")
paths.iconsDir = repoPath("icons")

log({ paths })

const exists = async (p) => {
  try {
    await fs.access(p)
    return true
  } catch (_) {
    return false
  }
}

const tryAwaitWithFallback = async (promise, fallback) => {
  try {
    return await promise
  } catch (_) {
    return fallback
  }
}

const isDir = (p) =>
  tryAwaitWithFallback(
    fs.stat(p).then((s) => s.isDirectory()),
    false
  )

const statFiles = async (dir, files) =>
  Object.fromEntries(
    await Promise.all(
      files.map(async (f) => [
        f,
        await tryAwaitWithFallback(fs.stat(path.join(dir, f)), null),
      ])
    )
  )

const syncDir = async (src, dest, files) => {
  log("syncDir", { src, dest, files })
  if (!(await isDir(src))) {
    throw new Error(`syncDir: expected src to be a directory: ${src}`)
  }
  if (!(await exists(dest))) {
    log("mkdir", dest, { recursive: true })
    await fs.mkdir(dest, { recursive: true })
  }

  const [srcFiles, destFiles] = await Promise.all([
    statFiles(src, files ?? (await fs.readdir(src))),
    statFiles(dest, files ?? (await fs.readdir(dest))),
  ])
  const srcFilesToCopy = new Set()
  for (const [srcFile, srcFileStats] of Object.entries(srcFiles)) {
    if (!srcFileStats) {
      throw new Error(`File not found: ${srcFile}`)
    }
    srcFilesToCopy.add(srcFile)
  }

  await Promise.all(
    Object.entries(destFiles).map(async ([name, destFileStats]) => {
      if (!destFileStats) {
        return
      }
      const srcFileStats = srcFiles[name]
      if (
        !srcFileStats ||
        srcFileStats.isDirectory() !== destFileStats.isDirectory()
      ) {
        const destFilePath = path.join(dest, name)
        log("rm", destFilePath, {
          recursive: destFileStats.isDirectory(),
        })
        await fs.rm(destFilePath, {
          recursive: destFileStats.isDirectory(),
        })
      } else if (srcFileStats.mtime <= destFileStats.mtime) {
        srcFilesToCopy.delete(name)
      }
    })
  )

  await Promise.all(
    Array.from(srcFilesToCopy).map(async (name) => {
      const srcFilePath = path.join(src, name)
      const destFilePath = path.join(dest, name)
      log("cp", srcFilePath, destFilePath, {
        preserveTimestamps: true,
        recursive: srcFiles[name].isDirectory(),
      })
      await fs.cp(srcFilePath, destFilePath, {
        preserveTimestamps: true,
        recursive: srcFiles[name].isDirectory(),
      })
    })
  )
}

const setupBuild = async () => {
  if (!(await exists(paths.buildDir))) {
    await fs.mkdir(paths.buildDir, { recursive: true })
  }
  await syncDir(paths.assetsDir, path.join(paths.buildDir, "assets"))
  await syncDir(paths.iconsDir, path.join(paths.buildDir, "icons"))
  const manifest = args.manifestV3 ? "manifest.v3.json" : "manifest.v2.json"
  log(
    "cp",
    path.join(paths.rootDir, manifest),
    path.join(paths.buildDir, "manifest.json")
  )
  await fs.cp(
    path.join(paths.rootDir, manifest),
    path.join(paths.buildDir, "manifest.json")
  )
}

const build = async () => {
  await setupBuild()

  await esbuild.build({
    entryPoints: [path.join(paths.srcDir, "index.js")],
    outfile: path.join(paths.buildDir, "bundle.js"),
    bundle: true,
    platform: "browser",
    format: "cjs",
    target: "esnext",
    logLevel: args.verbose ? "debug" : "info",
    minify: args.minify,
  })
}

build()
