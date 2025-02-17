-- Get it working
CREATE TABLE [dbo].[Works](
	[GeoNameId] nvarchar(255) PRIMARY KEY,
	[Name] nvarchar(max),
	[AsciiName] nvarchar(max),
	[AlternateNames] nvarchar(max),
	[Latitude] nvarchar(max),
	[Longitude] nvarchar(max),
	[FeatureClass] nvarchar(max),
	[FeatureCode] nvarchar(max),
	[CountryCode] nvarchar(max),
	[Cc2] nvarchar(max),
	[Admin1Code] nvarchar(max),
	[Admin2Code] nvarchar(max),
	[Admin3Code] nvarchar(max),
	[Admin4Code] nvarchar(max),
	[Population] nvarchar(max),
	[Elevation] nvarchar(max),
	[Dem] nvarchar(max),
	[Timezone] nvarchar(max),
	[ModificationDate] nvarchar(max) NULL
) 

GO
-- More accurate data types
CREATE TABLE allcountries (
	[GeoNameId] [int],
	[Name] [nvarchar](200),
	[AsciiName] [nvarchar](200),
	[AlternateNames] [nvarchar](max), -- problematic
	[Latitude] [float],
	[Longitude] [float],
	[FeatureClass] [char](1),
	[FeatureCode] [varchar](10),
	[CountryCode] [char](2),
	[Cc2] [varchar](255),
	[Admin1Code] [varchar](20),
	[Admin2Code] [varchar](80),
	[Admin3Code] [varchar](20),
	[Admin4Code] [varchar](20),
	[Population] [bigint],
	[Elevation] [varchar](255),
	[Dem] [int],
	[Timezone] [varchar](40),
	[ModificationDate] [smalldatetime]
)

-- Changed to dataset with no large datatypes
CREATE TABLE NoLargeVarchar (
	[CustomerId] [int] NULL,
	[FirstName] [nvarchar](40) NULL,
	[LastName] [nvarchar](20) NULL,
	[Company] [nvarchar](80) NULL,
	[Address] [nvarchar](70) NULL,
	[City] [nvarchar](40) NULL,
	[State] [varchar](40) NULL,
	[Country] [varchar](40) NULL,
	[PostalCode] [varchar](10) NULL,
	[Phone] [varchar](24) NULL,
	[Fax] [varchar](24) NULL,
	[Email] [varchar](60) NULL
)