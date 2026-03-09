-- ============================================================
--  Institut MiraLocks — Configuration Supabase
--  Copiez tout ce fichier dans : Supabase → SQL Editor → Run
-- ============================================================


-- ══════════════════════════════════════════
-- 1. TABLES
-- ══════════════════════════════════════════

CREATE TABLE IF NOT EXISTS site_settings (
  id         TEXT PRIMARY KEY,
  valeur     TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS blog_posts (
  id         BIGSERIAL PRIMARY KEY,
  titre      TEXT NOT NULL,
  extrait    TEXT,
  contenu    TEXT,
  photo_url  TEXT,
  categorie  TEXT DEFAULT 'Conseil',
  slug       TEXT,
  publie     BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS galerie_photos (
  id          BIGSERIAL PRIMARY KEY,
  titre       TEXT,
  description TEXT,
  photo_url   TEXT NOT NULL,
  categorie   TEXT DEFAULT 'creation',
  ordre       INTEGER DEFAULT 0,
  publie      BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS galerie_videos (
  id            BIGSERIAL PRIMARY KEY,
  titre         TEXT NOT NULL,
  description   TEXT,
  video_url     TEXT NOT NULL,
  thumbnail_url TEXT,
  duree         TEXT,
  publie        BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS avis_clients (
  id         BIGSERIAL PRIMARY KEY,
  nom        TEXT NOT NULL,
  localite   TEXT DEFAULT 'Lomé, Togo',
  etoiles    SMALLINT DEFAULT 5 CHECK (etoiles >= 1 AND etoiles <= 5),
  texte      TEXT NOT NULL,
  approuve   BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ══════════════════════════════════════════
-- 2. ROW LEVEL SECURITY (RLS)
-- ══════════════════════════════════════════

ALTER TABLE blog_posts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE galerie_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE galerie_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE avis_clients   ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings  ENABLE ROW LEVEL SECURITY;

-- Lecture publique
CREATE POLICY "public_read_blog"     ON blog_posts      FOR SELECT USING (publie = true);
CREATE POLICY "public_read_galerie"  ON galerie_photos  FOR SELECT USING (publie = true);
CREATE POLICY "public_read_videos"   ON galerie_videos  FOR SELECT USING (publie = true);
CREATE POLICY "public_read_avis"     ON avis_clients    FOR SELECT USING (approuve = true);
CREATE POLICY "public_read_settings" ON site_settings   FOR SELECT USING (true);

-- Dépôt d'avis public (sans connexion)
CREATE POLICY "public_insert_avis" ON avis_clients FOR INSERT WITH CHECK (true);

-- Admin : accès complet (nécessite d'être connecté)
CREATE POLICY "admin_all_blog"     ON blog_posts     FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_galerie"  ON galerie_photos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_videos"   ON galerie_videos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_avis"     ON avis_clients   FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_settings" ON site_settings  FOR ALL USING (auth.role() = 'authenticated');


-- ══════════════════════════════════════════
-- 3. STORAGE — bucket "miralocks-media"
--    (créer le bucket manuellement AVANT
--     d'exécuter ces politiques)
-- ══════════════════════════════════════════

CREATE POLICY "admin_upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'miralocks-media'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "admin_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'miralocks-media'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "public_read_storage" ON storage.objects
  FOR SELECT USING (bucket_id = 'miralocks-media');


-- ══════════════════════════════════════════
-- FIN — Tout est prêt !
-- ══════════════════════════════════════════
