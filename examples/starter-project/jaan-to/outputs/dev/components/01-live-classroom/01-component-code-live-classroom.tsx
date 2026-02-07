'use client';

import React, { useState, useRef, useEffect, useCallback } from 'react';

// ─── Types ────────────────────────────────────────────────────────────────────

export interface Participant {
  id: string;
  name: string;
  avatar?: string;
  isMuted: boolean;
  isCameraOff: boolean;
  isSpeaking: boolean;
  isHandRaised: boolean;
  connectionStatus: 'connected' | 'reconnecting' | 'disconnected';
}

export interface ChatMessageData {
  id: string;
  senderId: string;
  senderName: string;
  senderAvatar?: string;
  text: string;
  timestamp: Date;
}

export interface LiveClassroomProps {
  sessionId: string;
  instructor: Participant;
  participants: Participant[];
  chatMessages: ChatMessageData[];
  currentUserId: string;
  onToggleMic?: () => void;
  onToggleCamera?: () => void;
  onToggleHandRaise?: () => void;
  onToggleScreenShare?: () => void;
  onSendMessage?: (text: string) => void;
  onLeaveSession?: () => void;
  isMuted?: boolean;
  isCameraOff?: boolean;
  isHandRaised?: boolean;
  isScreenSharing?: boolean;
}

// ─── Icons (inline SVG) ───────────────────────────────────────────────────────

function MicIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 18.75a6 6 0 006-6v-1.5m-6 7.5a6 6 0 01-6-6v-1.5m6 7.5v3.75m-3.75 0h7.5M12 15.75a3 3 0 01-3-3V4.5a3 3 0 116 0v8.25a3 3 0 01-3 3z" />
    </svg>
  );
}

function MicOffIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 18.75a6 6 0 006-6v-1.5m-6 7.5a6 6 0 01-6-6v-1.5m6 7.5v3.75m-3.75 0h7.5M12 15.75a3 3 0 01-3-3V4.5a3 3 0 116 0v8.25a3 3 0 01-3 3z" />
      <path strokeLinecap="round" strokeLinejoin="round" d="M3 3l18 18" />
    </svg>
  );
}

function CameraIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
      <path strokeLinecap="round" d="M15.75 10.5l4.72-4.72a.75.75 0 011.28.53v11.38a.75.75 0 01-1.28.53l-4.72-4.72M4.5 18.75h9a2.25 2.25 0 002.25-2.25v-9a2.25 2.25 0 00-2.25-2.25h-9A2.25 2.25 0 002.25 7.5v9a2.25 2.25 0 002.25 2.25z" />
    </svg>
  );
}

function CameraOffIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 10.5l4.72-4.72a.75.75 0 011.28.53v11.38a.75.75 0 01-1.28.53l-4.72-4.72M12 18.75H4.5a2.25 2.25 0 01-2.25-2.25V9m12.841 9.091L16.5 19.5m-1.409-.409l-7.182-7.182m0 0L3.5 7.5" />
    </svg>
  );
}

function ScreenShareIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25A2.25 2.25 0 015.25 3h13.5A2.25 2.25 0 0121 5.25z" />
    </svg>
  );
}

function LeaveIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9" />
    </svg>
  );
}

function SendIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5" />
    </svg>
  );
}

function MenuIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
    </svg>
  );
}

function MutedSmallIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
      <path strokeLinecap="round" strokeLinejoin="round" d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
    </svg>
  );
}

// ─── Helper: Get Initials ─────────────────────────────────────────────────────

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
}

// ─── VideoTile ────────────────────────────────────────────────────────────────

function VideoTile({
  participant,
  size = 'sm',
}: {
  participant: Participant;
  size?: 'sm' | 'lg';
}) {
  const initials = getInitials(participant.name);

  return (
    <div
      className={`
        relative overflow-hidden rounded-2xl bg-stone-100 dark:bg-stone-800
        ${size === 'lg' ? 'aspect-video' : 'aspect-[4/3]'}
        ${
          participant.isSpeaking
            ? 'ring-2 ring-blue-500 ring-offset-2 ring-offset-stone-50 dark:ring-offset-stone-900'
            : ''
        }
        transition-shadow duration-200
      `}
      role="img"
      aria-label={`${participant.name}'s video${participant.isCameraOff ? ' (camera off)' : ''}${participant.isMuted ? ', muted' : ''}`}
    >
      {/* Camera off fallback — shows avatar initials */}
      {participant.isCameraOff ? (
        <div className="absolute inset-0 flex items-center justify-center bg-stone-200 dark:bg-stone-700">
          <div
            className={`
              flex items-center justify-center rounded-full
              bg-stone-300 font-semibold text-stone-600
              dark:bg-stone-600 dark:text-stone-300
              ${size === 'lg' ? 'h-20 w-20 text-2xl' : 'h-12 w-12 text-sm'}
            `}
          >
            {initials}
          </div>
        </div>
      ) : (
        /* Placeholder for video stream — in production, attach MediaStream here */
        <div className="absolute inset-0 bg-gradient-to-br from-stone-300 to-stone-400 dark:from-stone-600 dark:to-stone-700" />
      )}

      {/* Bottom overlay — name + status icons */}
      <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/60 to-transparent px-3 pb-2 pt-6">
        <div className="flex items-center gap-1.5">
          <span className="truncate text-xs font-medium text-white">
            {participant.name}
          </span>
          {participant.isMuted && (
            <MutedSmallIcon className="h-3.5 w-3.5 shrink-0 text-red-400" />
          )}
          {participant.isHandRaised && (
            <span className="text-sm" role="img" aria-label="Hand raised">
              ✋
            </span>
          )}
        </div>
      </div>

      {/* Connection indicator — top right */}
      <div className="absolute right-2 top-2">
        <div
          className={`h-2 w-2 rounded-full ${
            participant.connectionStatus === 'connected'
              ? 'bg-emerald-400'
              : participant.connectionStatus === 'reconnecting'
                ? 'animate-pulse bg-amber-400'
                : 'bg-red-400'
          }`}
          aria-label={`Connection: ${participant.connectionStatus}`}
        />
      </div>

      {/* Speaking indicator — animated bars, top left */}
      {participant.isSpeaking && (
        <div className="absolute left-2 top-2 flex items-end gap-0.5" aria-hidden="true">
          <div className="h-2 w-0.5 animate-[speakingBar_0.5s_ease-in-out_infinite_alternate] rounded-full bg-blue-400" />
          <div className="h-3 w-0.5 animate-[speakingBar_0.5s_ease-in-out_0.15s_infinite_alternate] rounded-full bg-blue-400" />
          <div className="h-1.5 w-0.5 animate-[speakingBar_0.5s_ease-in-out_0.3s_infinite_alternate] rounded-full bg-blue-400" />
        </div>
      )}
    </div>
  );
}

// ─── InstructorVideo ──────────────────────────────────────────────────────────
// The instructor gets a "stage" — elevated, prominent, warm shadow treatment

function InstructorVideo({ instructor }: { instructor: Participant }) {
  return (
    <section className="relative" aria-label="Instructor video">
      {/* Stage card with warm shadow for elevation */}
      <div className="rounded-3xl bg-white p-1 shadow-lg shadow-stone-200/50 dark:bg-stone-800 dark:shadow-stone-950/50">
        <VideoTile participant={instructor} size="lg" />
      </div>

      {/* LIVE badge — top left over the video */}
      <div className="absolute left-4 top-4 z-10">
        <span className="inline-flex items-center gap-1.5 rounded-full bg-white/90 px-2.5 py-1 text-xs font-semibold text-stone-700 shadow-sm backdrop-blur-sm dark:bg-stone-800/90 dark:text-stone-200">
          <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500" />
          LIVE
        </span>
      </div>
    </section>
  );
}

// ─── ParticipantGrid ──────────────────────────────────────────────────────────
// Displays up to 12 visible participant tiles, sorted: speakers first,
// then hand raised, then alphabetical. Shows "+N more" overflow tile.

function ParticipantGrid({ participants }: { participants: Participant[] }) {
  const sortedParticipants = [...participants].sort((a, b) => {
    if (a.isSpeaking !== b.isSpeaking) return a.isSpeaking ? -1 : 1;
    if (a.isHandRaised !== b.isHandRaised) return a.isHandRaised ? -1 : 1;
    return a.name.localeCompare(b.name);
  });

  const visibleParticipants = sortedParticipants.slice(0, 12);
  const overflow = participants.length - 12;

  if (participants.length === 0) {
    return (
      <section aria-label="Participants" className="py-8 text-center">
        <p className="text-sm text-stone-400 dark:text-stone-500">
          No participants yet
        </p>
      </section>
    );
  }

  return (
    <section aria-label={`Participants (${participants.length})`}>
      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6">
        {visibleParticipants.map((p) => (
          <VideoTile key={p.id} participant={p} />
        ))}
        {overflow > 0 && (
          <div className="flex aspect-[4/3] items-center justify-center rounded-2xl bg-stone-100 dark:bg-stone-800">
            <span className="text-sm font-medium text-stone-500 dark:text-stone-400">
              +{overflow} more
            </span>
          </div>
        )}
      </div>
    </section>
  );
}

// ─── ChatPanel ────────────────────────────────────────────────────────────────

function ChatPanel({
  messages,
  onSendMessage,
}: {
  messages: ChatMessageData[];
  onSendMessage?: (text: string) => void;
}) {
  const [draft, setDraft] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length]);

  const handleSend = useCallback(() => {
    if (draft.trim() && onSendMessage) {
      onSendMessage(draft.trim());
      setDraft('');
    }
  }, [draft, onSendMessage]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        handleSend();
      }
    },
    [handleSend],
  );

  const formatTime = (date: Date) =>
    date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  return (
    <div className="flex h-full flex-col">
      {/* Messages area with ARIA live region for screen readers */}
      <div
        className="flex-1 overflow-y-auto px-4 py-3"
        role="log"
        aria-label="Chat messages"
        aria-live="polite"
      >
        {messages.length === 0 ? (
          <div className="flex h-full items-center justify-center">
            <p className="text-center text-sm text-stone-400 dark:text-stone-500">
              No messages yet.
              <br />
              Start the conversation!
            </p>
          </div>
        ) : (
          <ul className="space-y-3">
            {messages.map((msg) => {
              const initials = getInitials(msg.senderName);
              return (
                <li key={msg.id} className="flex items-start gap-2.5">
                  <div className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-stone-200 text-[10px] font-semibold text-stone-600 dark:bg-stone-700 dark:text-stone-300">
                    {initials}
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-baseline gap-2">
                      <span className="text-xs font-semibold text-stone-700 dark:text-stone-200">
                        {msg.senderName}
                      </span>
                      <time className="text-[10px] text-stone-400 dark:text-stone-500">
                        {formatTime(msg.timestamp)}
                      </time>
                    </div>
                    <p className="mt-0.5 text-sm leading-relaxed text-stone-600 dark:text-stone-300">
                      {msg.text}
                    </p>
                  </div>
                </li>
              );
            })}
            <div ref={messagesEndRef} />
          </ul>
        )}
      </div>

      {/* Message input */}
      <div className="border-t border-stone-200 px-4 py-3 dark:border-stone-700">
        <div className="flex items-end gap-2">
          <textarea
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type a message..."
            rows={1}
            maxLength={1000}
            className="flex-1 resize-none rounded-xl border border-stone-200 bg-stone-50 px-3 py-2 text-sm text-stone-700 placeholder-stone-400 outline-none transition-colors focus:border-blue-400 focus:ring-1 focus:ring-blue-400 dark:border-stone-600 dark:bg-stone-800 dark:text-stone-200 dark:placeholder-stone-500 dark:focus:border-blue-500"
            aria-label="Chat message input"
          />
          <button
            onClick={handleSend}
            disabled={!draft.trim()}
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-blue-500 text-white transition-colors hover:bg-blue-600 disabled:cursor-not-allowed disabled:opacity-40 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2 dark:focus:ring-offset-stone-900"
            aria-label="Send message"
          >
            <SendIcon className="h-4 w-4" />
          </button>
        </div>
        {draft.length > 900 && (
          <p className="mt-1 text-right text-[10px] text-stone-400">
            {draft.length}/1000
          </p>
        )}
      </div>
    </div>
  );
}

// ─── ParticipantListPanel ─────────────────────────────────────────────────────

function ParticipantListPanel({
  participants,
}: {
  participants: Participant[];
}) {
  const [search, setSearch] = useState('');

  const filtered = participants.filter((p) =>
    p.name.toLowerCase().includes(search.toLowerCase()),
  );

  const sorted = [...filtered].sort((a, b) => {
    if (a.isHandRaised !== b.isHandRaised) return a.isHandRaised ? -1 : 1;
    if (a.isSpeaking !== b.isSpeaking) return a.isSpeaking ? -1 : 1;
    return a.name.localeCompare(b.name);
  });

  return (
    <div className="flex h-full flex-col">
      {/* Search input */}
      <div className="px-4 py-3">
        <input
          type="search"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search participants..."
          className="w-full rounded-xl border border-stone-200 bg-stone-50 px-3 py-2 text-sm text-stone-700 placeholder-stone-400 outline-none transition-colors focus:border-blue-400 focus:ring-1 focus:ring-blue-400 dark:border-stone-600 dark:bg-stone-800 dark:text-stone-200 dark:placeholder-stone-500"
          aria-label="Search participants"
        />
      </div>

      {/* Participant list */}
      <ul
        className="flex-1 overflow-y-auto px-4"
        role="list"
        aria-label="Participant list"
      >
        {sorted.map((p) => {
          const initials = getInitials(p.name);
          return (
            <li
              key={p.id}
              className="flex items-center gap-3 rounded-xl px-2 py-2 transition-colors hover:bg-stone-100 dark:hover:bg-stone-800"
            >
              <div className="relative">
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-stone-200 text-xs font-semibold text-stone-600 dark:bg-stone-700 dark:text-stone-300">
                  {initials}
                </div>
                <div
                  className={`absolute -bottom-0.5 -right-0.5 h-2.5 w-2.5 rounded-full border-2 border-white dark:border-stone-900 ${
                    p.connectionStatus === 'connected'
                      ? 'bg-emerald-400'
                      : p.connectionStatus === 'reconnecting'
                        ? 'bg-amber-400'
                        : 'bg-red-400'
                  }`}
                />
              </div>
              <div className="min-w-0 flex-1">
                <span className="block truncate text-sm font-medium text-stone-700 dark:text-stone-200">
                  {p.name}
                </span>
              </div>
              <div className="flex items-center gap-1">
                {p.isHandRaised && <span className="text-sm">✋</span>}
                {p.isMuted && (
                  <MutedSmallIcon className="h-3.5 w-3.5 text-red-400" />
                )}
              </div>
            </li>
          );
        })}
        {sorted.length === 0 && (
          <li className="py-8 text-center text-sm text-stone-400 dark:text-stone-500">
            {search
              ? `No participants found for "${search}"`
              : 'No participants yet'}
          </li>
        )}
      </ul>

      {/* Footer count */}
      <div className="border-t border-stone-200 px-4 py-2 dark:border-stone-700">
        <p className="text-xs text-stone-400 dark:text-stone-500">
          {participants.length} participant
          {participants.length !== 1 ? 's' : ''}
        </p>
      </div>
    </div>
  );
}

// ─── ToolbarButton ────────────────────────────────────────────────────────────

function ToolbarButton({
  active,
  danger,
  label,
  shortcut,
  onClick,
  children,
}: {
  active?: boolean;
  danger?: boolean;
  label: string;
  shortcut?: string;
  onClick?: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      className={`
        group relative flex h-11 w-11 items-center justify-center rounded-2xl
        transition-all duration-200
        focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2
        dark:focus:ring-offset-stone-900
        ${
          danger
            ? 'bg-red-500 text-white hover:bg-red-600'
            : active
              ? 'bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50'
              : 'bg-white text-stone-600 shadow-sm hover:bg-stone-50 dark:bg-stone-800 dark:text-stone-300 dark:hover:bg-stone-700'
        }
      `}
      aria-label={label}
      aria-pressed={active}
    >
      {children}
      {/* Tooltip on hover */}
      <span className="pointer-events-none absolute -top-10 left-1/2 -translate-x-1/2 whitespace-nowrap rounded-lg bg-stone-800 px-2.5 py-1 text-xs font-medium text-white opacity-0 shadow-lg transition-opacity group-hover:opacity-100 dark:bg-stone-700">
        {label}
        {shortcut && (
          <kbd className="ml-1.5 rounded bg-stone-700 px-1 py-0.5 text-[10px] text-stone-400 dark:bg-stone-600">
            {shortcut}
          </kbd>
        )}
      </span>
    </button>
  );
}

// ─── Toolbar ──────────────────────────────────────────────────────────────────

function Toolbar({
  isMuted = false,
  isCameraOff = false,
  isHandRaised = false,
  isScreenSharing = false,
  onToggleMic,
  onToggleCamera,
  onToggleHandRaise,
  onToggleScreenShare,
  onLeaveSession,
}: {
  isMuted?: boolean;
  isCameraOff?: boolean;
  isHandRaised?: boolean;
  isScreenSharing?: boolean;
  onToggleMic?: () => void;
  onToggleCamera?: () => void;
  onToggleHandRaise?: () => void;
  onToggleScreenShare?: () => void;
  onLeaveSession?: () => void;
}) {
  return (
    <nav
      className="flex items-center gap-2 rounded-2xl border border-stone-200 bg-white/80 px-3 py-2 shadow-lg backdrop-blur-md dark:border-stone-700 dark:bg-stone-900/80"
      role="toolbar"
      aria-label="Session controls"
    >
      <ToolbarButton
        active={isMuted}
        label={isMuted ? 'Unmute' : 'Mute'}
        shortcut="M"
        onClick={onToggleMic}
      >
        {isMuted ? (
          <MicOffIcon className="h-5 w-5" />
        ) : (
          <MicIcon className="h-5 w-5" />
        )}
      </ToolbarButton>

      <ToolbarButton
        active={isCameraOff}
        label={isCameraOff ? 'Turn on camera' : 'Turn off camera'}
        shortcut="V"
        onClick={onToggleCamera}
      >
        {isCameraOff ? (
          <CameraOffIcon className="h-5 w-5" />
        ) : (
          <CameraIcon className="h-5 w-5" />
        )}
      </ToolbarButton>

      <div
        className="mx-1 h-6 w-px bg-stone-200 dark:bg-stone-700"
        role="separator"
      />

      <ToolbarButton
        active={isHandRaised}
        label={isHandRaised ? 'Lower hand' : 'Raise hand'}
        shortcut="H"
        onClick={onToggleHandRaise}
      >
        <span
          className={`text-base ${isHandRaised ? '' : 'opacity-60 grayscale'}`}
        >
          ✋
        </span>
      </ToolbarButton>

      <ToolbarButton
        active={isScreenSharing}
        label={isScreenSharing ? 'Stop sharing' : 'Share screen'}
        shortcut="S"
        onClick={onToggleScreenShare}
      >
        <ScreenShareIcon className="h-5 w-5" />
      </ToolbarButton>

      <div
        className="mx-1 h-6 w-px bg-stone-200 dark:bg-stone-700"
        role="separator"
      />

      <ToolbarButton danger label="Leave session" shortcut="L" onClick={onLeaveSession}>
        <LeaveIcon className="h-5 w-5" />
      </ToolbarButton>
    </nav>
  );
}

// ─── LiveClassroom (Main Layout) ──────────────────────────────────────────────
// Grid layout: instructor video + participant grid on the left (65%),
// tabbed sidebar (Chat / Participants) on the right (35%).
// Stacks vertically on mobile with collapsible sidebar bottom sheet.

export default function LiveClassroom({
  sessionId,
  instructor,
  participants,
  chatMessages,
  currentUserId,
  onToggleMic,
  onToggleCamera,
  onToggleHandRaise,
  onToggleScreenShare,
  onSendMessage,
  onLeaveSession,
  isMuted = false,
  isCameraOff = false,
  isHandRaised = false,
  isScreenSharing = false,
}: LiveClassroomProps) {
  const [activeTab, setActiveTab] = useState<'chat' | 'participants'>('chat');
  const [sidebarOpen, setSidebarOpen] = useState(true);

  // ── Keyboard shortcuts ──
  // Disabled when user is focused on input/textarea
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      const target = e.target as HTMLElement;
      if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') return;

      switch (e.key.toLowerCase()) {
        case 'm':
          onToggleMic?.();
          break;
        case 'v':
          onToggleCamera?.();
          break;
        case 'h':
          onToggleHandRaise?.();
          break;
        case 's':
          onToggleScreenShare?.();
          break;
        case 'l':
          onLeaveSession?.();
          break;
        case 'c':
          setSidebarOpen((prev) => !prev);
          break;
      }
    };

    document.addEventListener('keydown', handler);
    return () => document.removeEventListener('keydown', handler);
  }, [
    onToggleMic,
    onToggleCamera,
    onToggleHandRaise,
    onToggleScreenShare,
    onLeaveSession,
  ]);

  return (
    <div className="flex h-screen flex-col bg-stone-50 font-[Plus_Jakarta_Sans,system-ui,sans-serif] text-stone-900 dark:bg-stone-900 dark:text-stone-100">
      {/* Accessibility: skip navigation links */}
      <a
        href="#instructor-video"
        className="sr-only focus:not-sr-only focus:absolute focus:z-50 focus:rounded-lg focus:bg-blue-500 focus:p-2 focus:text-white"
      >
        Skip to video
      </a>
      <a
        href="#chat-panel"
        className="sr-only focus:not-sr-only focus:absolute focus:z-50 focus:rounded-lg focus:bg-blue-500 focus:p-2 focus:text-white"
      >
        Skip to chat
      </a>

      {/* ── Header ── */}
      <header className="flex items-center justify-between border-b border-stone-200 px-4 py-2.5 dark:border-stone-800">
        <div className="flex items-center gap-3">
          <h1 className="text-sm font-semibold text-stone-700 dark:text-stone-200">
            Live Classroom
          </h1>
          <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2 py-0.5 text-[11px] font-medium text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400">
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-emerald-500" />
            Connected
          </span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs text-stone-400 dark:text-stone-500">
            {participants.length + 1} in session
          </span>
          {/* Sidebar toggle — visible on screens smaller than lg */}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="rounded-lg p-1.5 text-stone-500 transition-colors hover:bg-stone-100 dark:text-stone-400 dark:hover:bg-stone-800 lg:hidden"
            aria-label={sidebarOpen ? 'Close sidebar' : 'Open sidebar'}
            aria-expanded={sidebarOpen}
          >
            <MenuIcon className="h-5 w-5" />
          </button>
        </div>
      </header>

      {/* ── Main content ── */}
      <div className="flex min-h-0 flex-1">
        {/* Video area (main) */}
        <main
          className={`flex min-h-0 flex-1 flex-col gap-4 overflow-y-auto p-4 transition-all duration-300 ${
            sidebarOpen ? 'lg:pr-0' : ''
          }`}
          id="instructor-video"
          role="main"
        >
          <InstructorVideo instructor={instructor} />
          <ParticipantGrid participants={participants} />
        </main>

        {/* Sidebar (Chat / Participants tabs) */}
        <aside
          className={`
            flex w-80 shrink-0 flex-col border-l border-stone-200 bg-white
            transition-all duration-300
            dark:border-stone-800 dark:bg-stone-900
            ${
              sidebarOpen
                ? 'translate-x-0'
                : 'max-lg:translate-x-full lg:w-0 lg:overflow-hidden lg:border-0'
            }
            max-lg:fixed max-lg:inset-y-0 max-lg:right-0 max-lg:z-40 max-lg:shadow-2xl
          `}
          id="chat-panel"
          role="complementary"
          aria-label="Session sidebar"
        >
          {/* Mobile backdrop overlay */}
          {sidebarOpen && (
            <div
              className="fixed inset-0 z-[-1] bg-black/20 lg:hidden"
              onClick={() => setSidebarOpen(false)}
              aria-hidden="true"
            />
          )}

          {/* Tabs */}
          <div
            className="flex border-b border-stone-200 dark:border-stone-800"
            role="tablist"
          >
            {(['chat', 'participants'] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                role="tab"
                aria-selected={activeTab === tab}
                className={`
                  flex-1 px-4 py-2.5 text-xs font-semibold uppercase tracking-wider transition-colors
                  ${
                    activeTab === tab
                      ? 'border-b-2 border-blue-500 text-blue-600 dark:text-blue-400'
                      : 'text-stone-400 hover:text-stone-600 dark:text-stone-500 dark:hover:text-stone-300'
                  }
                `}
              >
                {tab === 'chat'
                  ? 'Chat'
                  : `Participants (${participants.length})`}
              </button>
            ))}
          </div>

          {/* Tab content */}
          <div className="min-h-0 flex-1" role="tabpanel">
            {activeTab === 'chat' ? (
              <ChatPanel messages={chatMessages} onSendMessage={onSendMessage} />
            ) : (
              <ParticipantListPanel
                participants={[instructor, ...participants]}
              />
            )}
          </div>
        </aside>
      </div>

      {/* ── Toolbar (bottom center) ── */}
      <footer className="flex justify-center pb-4 pt-2">
        <Toolbar
          isMuted={isMuted}
          isCameraOff={isCameraOff}
          isHandRaised={isHandRaised}
          isScreenSharing={isScreenSharing}
          onToggleMic={onToggleMic}
          onToggleCamera={onToggleCamera}
          onToggleHandRaise={onToggleHandRaise}
          onToggleScreenShare={onToggleScreenShare}
          onLeaveSession={onLeaveSession}
        />
      </footer>

      {/* Speaking animation keyframes */}
      <style>{`
        @keyframes speakingBar {
          from { transform: scaleY(0.4); }
          to { transform: scaleY(1.3); }
        }
      `}</style>
    </div>
  );
}
