/** Shapes of the Questkeeper player API (docs/external-api). */

export interface QkBlock {
  id: string;
  type: 'text' | 'image';
  markdownText?: string | null;
  imageUrl?: string | null;
  createdByUserId: string;
  isOwn: boolean;
  /** Only on own blocks: who besides the author may read it. */
  visibleTo?: string[] | null;
  createdAt: string;
  lastModifiedAt: string;
}

export interface QkDocument {
  id: string;
  campaignId: string;
  title: string;
  groupName: string;
  createdByUserId: string;
  isOwn: boolean;
  createdAt: string;
  /** Raw string as the API sent it; it goes back unchanged as expectedLastModifiedAt. */
  lastModifiedAt: string;
  blocks: QkBlock[];
}

export interface QkMember {
  userId: string;
  isDm: boolean;
  isYou: boolean;
  characters: { id: string; name: string }[];
}

export interface QkCampaign {
  id: string;
  name: string;
  dmUserId?: string;
}

export interface QkMe {
  userId: string;
  username: string;
  apiKey: { prefix: string; scopes: string[] };
}

export interface QkErrorBody {
  error?: string;
  message?: string;
  problems?: string[];
  currentLastModifiedAt?: string;
}
