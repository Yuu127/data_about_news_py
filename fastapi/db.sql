USE [master]
GO
/****** Object:  Database [news]    Script Date: Sun,26,05,2024 2:21:41 PM ******/
CREATE DATABASE [news]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'news', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\news.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'news_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\news_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [news] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [news].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [news] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [news] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [news] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [news] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [news] SET ARITHABORT OFF 
GO
ALTER DATABASE [news] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [news] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [news] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [news] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [news] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [news] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [news] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [news] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [news] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [news] SET  DISABLE_BROKER 
GO
ALTER DATABASE [news] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [news] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [news] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [news] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [news] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [news] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [news] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [news] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [news] SET  MULTI_USER 
GO
ALTER DATABASE [news] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [news] SET DB_CHAINING OFF 
GO
ALTER DATABASE [news] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [news] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [news] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [news] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [news] SET QUERY_STORE = ON
GO
ALTER DATABASE [news] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [news]
GO
/****** Object:  Table [dbo].[articles]    Script Date: Sun,26,05,2024 2:21:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[articles](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[source_id] [varchar](255) NULL,
	[source_name] [varchar](255) NULL,
	[author] [varchar](255) NULL,
	[title] [varchar](max) NULL,
	[description] [varchar](max) NULL,
	[url] [varchar](max) NULL,
	[published_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[Get_data_article]    Script Date: Sun,26,05,2024 2:21:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hoa hòe
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_data_article]
	@action varchar(10)
AS
BEGIN
	if(@action = 'test')
	begin
	SET NOCOUNT ON;
		--SELECT * FROM articles FOR JSON PATH;
		--SELECT * FROM articles FOR JSON AUTO, ROOT('articles');
		SELECT id, source_name, url, published_at
		FROM articles
		FOR JSON AUTO, ROOT('articles');

	end
END
GO
/****** Object:  StoredProcedure [dbo].[InsertArticle]    Script Date: Sun,26,05,2024 2:21:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertArticle]
    @json VARCHAR(max)

AS
BEGIN
   INSERT INTO articles (source_id, source_name, author, title, description, url, published_at)
	SELECT json_data.source_id, json_data.source_name, json_data.author, json_data.title, json_data.description, json_data.url, json_data.published_at
	FROM OPENJSON(@json)
	WITH (
		source_id NVARCHAR(1000),
		source_name NVARCHAR(1000),
		author NVARCHAR(1000),
		title NVARCHAR(4000),
		description NVARCHAR(MAX),
		url NVARCHAR(MAX),
		published_at DATETIME
	) AS json_data
	LEFT JOIN articles ON articles.source_id = json_data.source_id
					   AND articles.source_name = json_data.source_name
					   AND articles.author = json_data.author
					   AND articles.title = json_data.title
					   AND articles.description = json_data.description
					   AND articles.url = json_data.url
					   AND articles.published_at = json_data.published_at
	WHERE articles.source_id IS NULL


END;

--delete  from articles
--select * from articles

 -- exec [InsertArticle] @json = '[{"source_id":"cnn","source_name":"CNN","author":"Deblina Chakraborty","title":"Boeing Starliner historic crewed launch delayed again indefinitely - CNN","description":"After reporting a helium leak in the spacecraft, NASA has taken the next target date for the highly anticipated launch off the table — without immediately naming a new one.","url":"https://www.cnn.com/2024/05/22/world/boeing-starliner-crewed-launch-delayed-indefinitely-scn/index.html","published_at":"2024-05-22T14:14:00Z"},{"source_id":"nbc-news","source_name":"NBC News","author":"Patrick Smith","title":"Deadly tornado devastates Iowa town as severe weather moves east - NBC News","description":"Central Iowa was reeling Wednesday morning after what police described as a \"devastating\" tornado laid waste to rural communities and killed an unknown number of people.","url":"https://www.nbcnews.com/news/us-news/deadly-tornado-devastates-iowa-town-severe-weather-moves-south-rcna153430","published_at":"2024-05-22T13:49:46Z"}]'
GO
/****** Object:  StoredProcedure [dbo].[SP_insert_article]    Script Date: Sun,26,05,2024 2:21:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Creating the stored procedure
CREATE PROCEDURE [dbo].[SP_insert_article]
    @action VARCHAR(10),
    @source_id VARCHAR(255) = NULL,
    @source_name VARCHAR(255) = NULL,
    @author VARCHAR(255) = NULL,
    @title VARCHAR(MAX) = NULL,
    @description VARCHAR(MAX) = NULL,
    @url VARCHAR(MAX) = NULL,
    @published_at DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@action = 'insert_data')
    BEGIN
        -- Insert data into the articles table
        IF NOT EXISTS (
            SELECT 1
            FROM articles
            WHERE source_id = @source_id
              AND source_name = @source_name
              AND author = @author
              AND title = @title
              AND description = @description
              AND url = @url
              AND published_at = @published_at
        )
        BEGIN
            INSERT INTO articles (source_id, source_name, author, title, description, url, published_at)
            VALUES (@source_id, @source_name, @author, @title, @description, @url, @published_at);
        END
    END
    ELSE IF (@action = 'get_data')
    BEGIN
        DECLARE @json NVARCHAR(MAX) = '';

        -- Build JSON string
        SELECT @json += FORMATMESSAGE(N'{"source_id":"%s","source_name":"%s","author":"%s","title":"%s","description":"%s","url":"%s","published_at":"%s"},',
            source_id, source_name, author, title, description, url, FORMAT(published_at, 'yyyy-MM-ddTHH:mm:ss'))
        FROM articles;

        -- Remove trailing comma if exists
        IF LEN(@json) > 0
        BEGIN
            SET @json = LEFT(@json, LEN(@json) - 1);
        END

        -- Wrap the string with square brackets to form JSON array
        SET @json = '[' + @json + ']';

        -- Return the JSON result
        SELECT @json AS jsonResult;
    END
END;
GO
USE [master]
GO
ALTER DATABASE [news] SET  READ_WRITE 
GO
