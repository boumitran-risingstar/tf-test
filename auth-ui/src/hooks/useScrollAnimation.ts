'use client';
import { useEffect, useRef, useState } from 'react';

export const useScrollAnimation = () => {
  const [isVisible, setIsVisible] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const onScroll = () => {
      if (ref.current) {
        const top = ref.current.getBoundingClientRect().top;
        const windowHeight = window.innerHeight;
        if (top < windowHeight * 0.8) { // Trigger when 80% of the element is visible
          setIsVisible(true);
        }
      }
    };

    window.addEventListener('scroll', onScroll);
    onScroll(); // Check initial position

    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return { ref, isVisible };
};