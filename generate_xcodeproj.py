#!/usr/bin/env python3
import os
import hashlib

def make_uuid(name):
    """Generates a stable 24-character hexadecimal string representing a UUID."""
    h = hashlib.sha1(name.encode('utf-8')).hexdigest()[:24].upper()
    return h

def main():
    project_dir = os.path.dirname(os.path.abspath(__file__))
    source_root = os.path.join(project_dir, "XFace")
    
    # 1. Discover all source files and resources
    swift_files = []
    resource_files = []
    
    for root, dirs, files in os.walk(source_root):
        # Prevent traversing inside .xcassets folders and add them as resource files
        for d in list(dirs):
            if d.endswith('.xcassets'):
                rel_path = os.path.relpath(os.path.join(root, d), project_dir)
                resource_files.append(rel_path)
                dirs.remove(d) # Prune
                
        for file in files:
            if file.startswith('.'):
                continue
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, project_dir)
            if file.endswith('.swift'):
                swift_files.append(rel_path)
            elif file.endswith('.json') or file.endswith('.png') or file.endswith('.icns'):
                resource_files.append(rel_path)

    print(f"Discovered Swift files: {swift_files}")
    print(f"Discovered Resource files: {resource_files}")
    
    # 2. Setup project elements UUIDs
    target_uuid = make_uuid("target_XFace")
    product_uuid = make_uuid("product_XFace")
    project_uuid = make_uuid("project_XFace")
    
    main_group_uuid = make_uuid("group_XFace_Root")
    products_group_uuid = make_uuid("group_Products")
    
    sources_build_phase_uuid = make_uuid("phase_sources")
    resources_build_phase_uuid = make_uuid("phase_resources")
    frameworks_build_phase_uuid = make_uuid("phase_frameworks")
    
    build_config_list_target_uuid = make_uuid("config_list_target")
    build_config_list_project_uuid = make_uuid("config_list_project")
    
    debug_config_target_uuid = make_uuid("config_debug_target")
    release_config_target_uuid = make_uuid("config_release_target")
    debug_config_project_uuid = make_uuid("config_debug_project")
    release_config_project_uuid = make_uuid("config_release_project")
    
    # Build list of file references and build files
    file_references = []
    build_files = []
    
    # Add product reference
    product_ref_uuid = make_uuid("product_ref_XFace")
    file_references.append(
        f'\t\t{product_ref_uuid} /* XFace.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = XFace.app; sourceTree = BUILT_PRODUCTS_DIR; }};'
    )
    
    # Add source file references & build files
    sources_entries = []
    for f in swift_files:
        filename = os.path.basename(f)
        ref_uuid = make_uuid(f"ref_{f}")
        build_uuid = make_uuid(f"build_{f}")
        file_references.append(
            f'\t\t{ref_uuid} /* {filename} */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = "{filename}"; sourceTree = "<group>"; }};'
        )
        build_files.append(
            f'\t\t{build_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref_uuid} /* {filename} */; }};'
        )
        sources_entries.append((f, ref_uuid, build_uuid))
        
    # Add resource file references & build files
    resources_entries = []
    for r in resource_files:
        filename = os.path.basename(r)
        ref_uuid = make_uuid(f"ref_{r}")
        build_uuid = make_uuid(f"build_{r}")
        
        file_type = "text.json"
        if r.endswith('.png'):
            file_type = "image.png"
        elif r.endswith('.icns'):
            file_type = "image.icns"
        elif r.endswith('.xcassets'):
            file_type = "folder.assetcatalog"
            
        file_references.append(
            f'\t\t{ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = "{filename}"; sourceTree = "<group>"; }};'
        )
        build_files.append(
            f'\t\t{build_uuid} /* {filename} in Resources */ = {{isa = PBXBuildFile; fileRef = {ref_uuid} /* {filename} */; }};'
        )
        resources_entries.append((r, ref_uuid, build_uuid))
        
    # 3. Create PBXGroup section
    # We will build sub-groups mapping to folders
    subgroups = ["App", "Models", "Importers", "Exporters", "Converters", "Services", "Utilities", "Resources", "ViewModels", "Views"]
    subgroup_uuids = {g: make_uuid(f"group_{g}") for g in subgroups}
    
    group_declarations = []
    
    # Root Group
    children_uuids = [subgroup_uuids[g] for g in subgroups]
    children_uuids_str = ",\n\t\t\t\t".join(children_uuids)
    group_declarations.append(f"""\t\t{main_group_uuid} /* CustomTemplate */ = {{
			isa = PBXGroup;
			children = (
				{children_uuids_str},
				{products_group_uuid} /* Products */,
			);
			sourceTree = "<group>";
		}};""")
    
    # Products Group
    group_declarations.append(f"""\t\t{products_group_uuid} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{product_ref_uuid} /* XFace.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};""")
    
    # Folder Groups
    for g in subgroups:
        g_uuid = subgroup_uuids[g]
        # Find files in this subgroup
        g_children = []
        for path, ref_uuid, _ in (sources_entries + resources_entries):
            parts = path.split(os.sep)
            if len(parts) > 1 and parts[1] == g:
                g_children.append(f'\t\t\t\t{ref_uuid} /* {parts[-1]} */,')
                
        g_children_str = "\n".join(g_children)
        group_declarations.append(f"""\t\t{g_uuid} /* {g} */ = {{
			isa = PBXGroup;
			children = (
{g_children_str}
			);
			name = {g};
			path = XFace/{g};
			sourceTree = "<group>";
		}};""")

    # 4. Generate build configs
    # Target configurations
    target_debug_settings = """{
					ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES;
					CODE_SIGN_STYLE = Automatic;
					COMBINE_HIDPI_IMAGES = YES;
					DEVELOPMENT_ASSET_PATHS = "";
					ENABLE_PREVIEWS = YES;
					GENERATE_INFOPLIST_FILE = NO;
					INFOPLIST_FILE = "XFace/Resources/Info.plist";
					LD_RUNPATH_SEARCH_PATHS = (
						"$(inherited)",
						"@executable_path/../Frameworks",
					);
					MACOSX_DEPLOYMENT_TARGET = 15.0;
					PRODUCT_BUNDLE_IDENTIFIER = com.bhoomi.XFace;
					PRODUCT_NAME = "$(TARGET_NAME)";
					SWIFT_VERSION = 6.0;
				}"""
                
    target_release_settings = target_debug_settings
    
    # Project configurations
    project_debug_settings = """{
					ALWAYS_SEARCH_USER_PATHS = NO;
					CLANG_ANALYZER_NONNULL = YES;
					CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
					CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
					CLANG_ENABLE_MODULES = YES;
					CLANG_ENABLE_OBJC_ARC = YES;
					CLANG_ENABLE_OBJC_WEAK = YES;
					CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
					CLANG_WARN_BOOL_CONVERSION = YES;
					CLANG_WARN_COMMA = YES;
					CLANG_WARN_CONSTANT_CONVERSION = YES;
					CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
					CLANG_WARN_DIRECT_OBJC_RESERVED_IMPROPER_ACCESS = YES;
					CLANG_WARN_DOCUMENTATION_FILES = YES;
					CLANG_WARN_EMPTY_BODY = YES;
					CLANG_WARN_ENUM_CONVERSION = YES;
					CLANG_WARN_INFINITE_RECURSION = YES;
					CLANG_WARN_INT_CONVERSION = YES;
					CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
					CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
					CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
					CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
					CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
					CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
					CLANG_WARN_STRICT_PROTOTYPES = YES;
					CLANG_WARN_SUSPICIOUS_MOVE = YES;
					CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
					CLANG_WARN_UNREACHABLE_CODE = YES;
					COPY_PHASE_STRIP = NO;
					DEBUG_INFORMATION_FORMAT = dwarf;
					ENABLE_STRICT_OBJC_MSGSEND = YES;
					ENABLE_TESTABILITY = YES;
					GCC_C_LANGUAGE_STANDARD = gnu17;
					GCC_DYNAMIC_NO_PIC = NO;
					GCC_NO_COMMON_BLOCKS = YES;
					GCC_OPTIMIZATION_LEVEL = 0;
					GCC_PREPROCESSOR_DEFINITIONS = (
						"DEBUG=1",
						"$(inherited)",
					);
					GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
					GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
					GCC_WARN_UNDECLARED_SELECTOR = YES;
					GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
					GCC_WARN_UNUSED_FUNCTION = YES;
					GCC_WARN_UNUSED_VARIABLE = YES;
					MACOSX_DEPLOYMENT_TARGET = 15.0;
					MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
					MTL_FAST_MATH = YES;
					ONLY_ACTIVE_ARCH = YES;
					SDKROOT = macosx;
					SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
					SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				}"""
                
    project_release_settings = project_debug_settings.replace("GCC_OPTIMIZATION_LEVEL = 0;", "GCC_OPTIMIZATION_LEVEL = s;").replace("ONLY_ACTIVE_ARCH = YES;", "ONLY_ACTIVE_ARCH = NO;").replace('SWIFT_OPTIMIZATION_LEVEL = "-Onone";', 'SWIFT_OPTIMIZATION_LEVEL = "-O";')

    # Build file configurations
    pbx_sources = "\n".join([f"\t\t\t\t{bu} /* {os.path.basename(path)} in Sources */," for path, _, bu in sources_entries])
    pbx_resources = "\n".join([f"\t\t\t\t{bu} /* {os.path.basename(path)} in Resources */," for path, _, bu in resources_entries])

    # 5. Assemble project file contents
    build_files_str = "\n".join(build_files)
    file_references_str = "\n".join(file_references)
    group_declarations_str = "\n".join(group_declarations)
    
    project_contents = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{build_files_str}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{file_references_str}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{frameworks_build_phase_uuid} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{group_declarations_str}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{target_uuid} /* XFace */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {build_config_list_target_uuid} /* Build configuration list for PBXNativeTarget "XFace" */;
			buildPhases = (
				{sources_build_phase_uuid} /* Sources */,
				{frameworks_build_phase_uuid} /* Frameworks */,
				{resources_build_phase_uuid} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = XFace;
			productName = XFace;
			productReference = {product_ref_uuid} /* XFace.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{project_uuid} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {{
					{target_uuid} = {{
						CreatedOnToolsVersion = 15.0;
						LastSwiftMigration = 1500;
					}};
				}};
			}};
			buildConfigurationList = {build_config_list_project_uuid} /* Build configuration list for PBXProject "XFace" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group_uuid} /* CustomTemplate */;
			productRefGroup = {products_group_uuid} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{target_uuid} /* XFace */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{resources_build_phase_uuid} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{pbx_resources}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{sources_build_phase_uuid} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{pbx_sources}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{debug_config_project_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {project_debug_settings};
			name = Debug;
		}};
		{release_config_project_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {project_release_settings};
			name = Release;
		}};
		{debug_config_target_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {target_debug_settings};
			name = Debug;
		}};
		{release_config_target_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {target_release_settings};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{build_config_list_project_uuid} /* Build configuration list for PBXProject "XFace" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_config_project_uuid} /* Debug */,
				{release_config_project_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{build_config_list_target_uuid} /* Build configuration list for PBXNativeTarget "XFace" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_config_target_uuid} /* Debug */,
				{release_config_target_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {project_uuid} /* Project object */;
}}
"""
    
    # Write PBXPROJ
    xcodeproj_dir = os.path.join(project_dir, "XFace.xcodeproj")
    os.makedirs(xcodeproj_dir, exist_ok=True)
    pbxproj_path = os.path.join(xcodeproj_dir, "project.pbxproj")
    with open(pbxproj_path, "w") as f:
        f.write(project_contents)
    print(f"Generated {pbxproj_path}")
    
    # Write Workspace contents
    workspace_dir = os.path.join(xcodeproj_dir, "project.xcworkspace")
    os.makedirs(workspace_dir, exist_ok=True)
    workspace_data = """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""
    with open(os.path.join(workspace_dir, "contents.xcworkspacedata"), "w") as f:
        f.write(workspace_data)
        
    # Write Scheme
    scheme_dir = os.path.join(xcodeproj_dir, "xcshareddata", "xcschemes")
    os.makedirs(scheme_dir, exist_ok=True)
    scheme_data = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{target_uuid}"
               BuildableName = "XFace.app"
               BlueprintName = "XFace"
               ReferencedContainer = "container:XFace.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useLaunchSchemeArgsEnv = "YES"
      ignoringPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_uuid}"
            BuildableName = "XFace.app"
            BlueprintName = "XFace"
            ReferencedContainer = "container:XFace.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useLaunchSchemeArgsEnv = "YES"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_uuid}"
            BuildableName = "XFace.app"
            BlueprintName = "XFace"
            ReferencedContainer = "container:XFace.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    with open(os.path.join(scheme_dir, "XFace.xcscheme"), "w") as f:
        f.write(scheme_data)
    print("Generated Scheme and Workspace.")

if __name__ == "__main__":
    main()
